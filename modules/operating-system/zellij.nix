{
  flake.homeModules.zellij = {
    programs.zellij = {
      enable = true;
      settings = {
        # default_layout = "compact";
        session_serialization = false;
      };
    };
  };
}
