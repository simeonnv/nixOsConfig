import re

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

SERVICE = "org.usbguard1"
DEVICES_PATH = "/org/usbguard1/Devices"
DEVICES_IFACE = "org.usbguard.Devices1"
TARGET_ALLOW = 0
TARGET_BLOCK = 1
EVENT_REMOVE = 3

CLASSES = {
    "01": "audio",
    "02": "communications",
    "03": "HID (keyboard/mouse)",
    "06": "imaging",
    "07": "printer",
    "08": "mass storage",
    "09": "hub",
    "0a": "CDC data",
    "0b": "smart card",
    "0e": "video",
    "e0": "wireless",
    "ef": "miscellaneous",
    "fe": "application specific",
    "ff": "vendor specific",
}

system_bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
session_bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
pending = {}
order = []
current = None


def field(rule, pattern):
    match = re.search(pattern, rule)
    return match.group(1) if match else ""


def describe(rule):
    vid_pid = field(rule, r"\bid ([0-9a-f*]{4}:[0-9a-f*]{4})")
    name = field(rule, r'\bname "([^"]*)"') or "Unknown device"
    port = field(rule, r'\bvia-port "([^"]*)"') or "?"
    interfaces = field(rule, r"\bwith-interface (\{[^}]*\}|\S+)")
    classes = re.findall(r"\b([0-9a-f]{2}):[0-9a-f*]{2}:[0-9a-f*]{2}\b", interfaces)
    kinds = ", ".join(sorted({CLASSES.get(c) or c for c in classes})) or "unknown"
    return f"{name} [{vid_pid}]", f"port {port}\ninterfaces: {kinds}"


def notify(summary, body):
    try:
        reply = session_bus.call_sync(
            "org.freedesktop.Notifications",
            "/org/freedesktop/Notifications",
            "org.freedesktop.Notifications",
            "Notify",
            GLib.Variant(
                "(susssasa{sv}i)",
                (
                    "USBGuard",
                    0,
                    "drive-removable-media",
                    summary,
                    body,
                    [],
                    {"urgency": GLib.Variant("y", 2)},
                    0,
                ),
            ),
            GLib.VariantType("(u)"),
            Gio.DBusCallFlags.NONE,
            -1,
            None,
        )
        return reply.unpack()[0]
    except GLib.Error:
        return 0


def close_notification(notification_id):
    if not notification_id:
        return
    session_bus.call(
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications",
        "CloseNotification",
        GLib.Variant("(u)", (notification_id,)),
        None,
        Gio.DBusCallFlags.NONE,
        -1,
        None,
        None,
        None,
    )


def enqueue(device_id, rule):
    if device_id == current or device_id in pending:
        return
    pending[device_id] = rule
    order.append(device_id)
    advance()


def advance():
    global current
    if current is not None or not order:
        return
    current = order.pop(0)
    summary, body = describe(pending.pop(current))
    notification_id = notify(
        f"USB device blocked: {summary}",
        f"{body}\nAuthenticate to allow, cancel to keep it blocked.",
    )
    system_bus.call(
        SERVICE,
        DEVICES_PATH,
        DEVICES_IFACE,
        "applyDevicePolicy",
        GLib.Variant("(uub)", (current, TARGET_ALLOW, False)),
        GLib.VariantType("(u)"),
        Gio.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION,
        GLib.MAXINT,
        None,
        on_applied,
        notification_id,
    )


def on_applied(bus, result, notification_id):
    global current
    try:
        bus.call_finish(result)
        print(f"device {current} allowed", flush=True)
    except GLib.Error as error:
        print(f"device {current} left blocked: {error.message}", flush=True)
    close_notification(notification_id)
    current = None
    advance()


def on_policy_applied(_bus, _sender, _path, _iface, _signal, params, _data):
    device_id, target, rule, _rule_id, _attrs = params.unpack()
    if target == TARGET_BLOCK:
        enqueue(device_id, rule)


def on_presence_changed(_bus, _sender, _path, _iface, _signal, params, _data):
    device_id, event, _target, _rule, _attrs = params.unpack()
    if event == EVENT_REMOVE and device_id in pending:
        del pending[device_id]
        order.remove(device_id)


def subscribe(signal, handler):
    system_bus.signal_subscribe(
        SERVICE,
        DEVICES_IFACE,
        signal,
        DEVICES_PATH,
        None,
        Gio.DBusSignalFlags.NONE,
        handler,
        None,
    )


def main():
    subscribe("DevicePolicyApplied", on_policy_applied)
    subscribe("DevicePresenceChanged", on_presence_changed)
    reply = system_bus.call_sync(
        SERVICE,
        DEVICES_PATH,
        DEVICES_IFACE,
        "listDevices",
        GLib.Variant("(s)", ("block",)),
        GLib.VariantType("(a(us))"),
        Gio.DBusCallFlags.NONE,
        -1,
        None,
    )
    for device_id, rule in reply.unpack()[0]:
        enqueue(device_id, rule)
    GLib.MainLoop().run()


main()
