{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "chlouzada";
    userEmail = "chlouzada@gmail.com"; 

    aliases = {
      co = "checkout";
      ci = "commit";
      undo = "reset --soft HEAD^";
    };

    extraConfig = {
      init.defaultBranch = "main";

      push.default = "simple"; 
      push.autoSetupRemote = true;

      url."git@github.com:".pushInsteadOf = "https://github.com";

      url."git@github.com:".insteadOf = "gh:";
      url."https://github.com/".insteadOf = "gh/:";

      url."git@gitlab.com:".insteadOf = "gl:";
      url."https://gitlab.com/".insteadOf = "gl/:";

      url."git@gitlab.eurekka.technology:eurekka-equipe-interna/".insteadOf = "eurekka:";
    };
  };
}
