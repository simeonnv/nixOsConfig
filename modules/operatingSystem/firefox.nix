{ownerProfile, ...}: {
  flake.homeModules.firefox = {...}: {
    programs.firefox = {
      enable = true;
      profiles.${ownerProfile.name} = {
        name = ownerProfile.name;
        isDefault = true;
      };
    };
  };
}
