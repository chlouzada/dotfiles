{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "chlouzada";
        email = "chlouzada@gmail.com";
      };

      alias = {
        co = "checkout";
        ci = "commit";
        undo = "!f() { [[ \"$1\" == \"--hard\" ]] && git reset --hard HEAD~${2:-1} || git reset --soft HEAD~${1:-1}; }; f";
      };

      init.defaultBranch = "main";

      push = {
        default = "simple";
        autoSetupRemote = true;
      };

      url."git@github.com:" = {
        pushInsteadOf = "https://github.com";
        insteadOf = "gh:";
      };

      url."https://github.com/" = {
        insteadOf = "gh/:";
      };

      url."git@gitlab.com:" = {
        insteadOf = "gl:";
      };

      url."https://gitlab.com/" = {
        insteadOf = "gl/:";
      };

      url."git@gitlab.eurekka.technology:eurekka-equipe-interna/" = {
        insteadOf = "eurekka:";
      };
    };
  };
}