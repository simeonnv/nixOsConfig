(require-builtin steel/time)
(require "helix/editor.scm")
(require "helix/misc.scm")
(require (prefix-in helix.static. "helix/static.scm"))

(#%require-dylib "libhelix_discord_rpc"
  (only-in
    DiscordRPC::new
    DiscordRPC::connect
    DiscordRPC::set_activity
    DiscordRPC::set_idle))

(provide discord-rpc-connect discord-rpc-update)

(define server (DiscordRPC::new))
(define is-connected #f)

(define *throttle-ms* 4000)
(define *last-update-ms* 0)
(define *last-state* "")
(define *flush-pending?* #f)

(define (any-view-open?)
  (let loop ([docs (editor-all-documents)])
    (cond [(null? docs) #f]
          [(editor-doc-in-view? (car docs)) #t]
          [else (loop (cdr docs))])))

(define (current-doc-path)
  (editor-document->path (editor->doc-id (editor-focus))))

(define (send-activity! path row col)
  (DiscordRPC::set_activity server path (helix-find-workspace) row col))

(define (schedule-flush!)
  (unless *flush-pending?*
    (set! *flush-pending?* #t)
    (enqueue-thread-local-callback-with-delay
     *throttle-ms*
     (lambda ()
       (set! *flush-pending?* #f)
       (discord-rpc-update)))))

(define (discord-rpc-update)
  (when (and is-connected (any-view-open?))
    (let ([path (current-doc-path)])
      (when path
        (let* ([row (+ 1 (helix.static.get-current-line-number))]
               [col (+ 1 (helix.static.get-current-column-number))]
               [state (string-append path ":" (number->string row) ":" (number->string col))]
               [now (current-milliseconds)])
          (unless (equal? state *last-state*)
            (if (>= (- now *last-update-ms*) *throttle-ms*)
                (begin
                  (set! *last-state* state)
                  (set! *last-update-ms* now)
                  (send-activity! path row col))
                (schedule-flush!))))))))

(register-hook! 'selection-did-change (lambda (_) (discord-rpc-update)))
(register-hook! 'post-command (lambda (_) (discord-rpc-update)))

(define (discord-rpc-connect)
  (if is-connected
      "Websocket already connected"
      (begin
        (DiscordRPC::connect server)
        (set! is-connected #t)
        (set! *last-update-ms* 0)
        (discord-rpc-update)
        "Websocket connected")))
