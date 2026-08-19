{
  description = "Ryosuke's macOS Dotfiles with nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  let
    user = let envUser = builtins.getEnv "USER"; in
      if envUser != "" then envUser
      else throw "USER environment variable is empty. Run with: sudo -E env USER=\"$USER\" HOSTNAME=\"$(scutil --get LocalHostName)\" ... --impure";
    hostname = let envHostname = builtins.getEnv "HOSTNAME"; in
      if envHostname != "" then envHostname
      else throw "HOSTNAME environment variable is empty. Run with: sudo -E env USER=\"$USER\" HOSTNAME=\"$(scutil --get LocalHostName)\" ... --impure";
    system = "aarch64-darwin";
  in {
    darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs user hostname; };
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.config.allowUnfree = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users."${user}" = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs user hostname; };
        }
      ];
    };
  };
}
