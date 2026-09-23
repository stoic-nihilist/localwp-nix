# localwp-nix

A declarative Nix Flake providing a fully wrapped [WordPress Local (LocalWP)](https://localwp.com/) package for NixOS inside a `buildFHSEnv` container.

It includes all dynamic runtime libraries required by LocalWP and its bundled site services (`Nginx`, `PHP`, `MariaDB`, `WP-CLI`, and router services).

---

## 🚀 Quick Start

### Option 1: Run directly without installing
```bash
nix run github:kaiguaaaa/localwp-nix
```

### Option 2: Install via `nix profile`
```bash
nix profile install github:kaiguaaaa/localwp-nix
```

### Option 3: Add to NixOS Configuration (Flakes)

1. Add the flake to your `flake.nix` inputs:
   ```nix
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     localwp.url = "github:stoic-nihilist/localwp-nix";
   };
   ```

2.1 Add to `environment.systemPackages` in `configuration.nix`:
   ```nix
   environment.systemPackages = [
     inputs.localwp.packages.${pkgs.system}.default
   ];
   ```

2.2 Add to `home.packages` in `home.nix`:
	home.packages = with pkgs; [
             inputs.localwp.packages.${pkgs.system}.default
		];


3. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

   or
   ```bash
   home-manager switch --flake .
   ```
---

## ⚠️ Essential NixOS Configuration (Router Mode)

NixOS manages `/etc/hosts` declaratively as a read-only symlink to `/nix/store/`. Because of this, LocalWP's default attempt to write to `/etc/hosts` will fail with an "antivirus lock" error.

**To fix this on your first run:**

1. Open **Local**.
2. Go to **Preferences** → **Advanced**.
3. Change **Router Mode** from **Site Domains** to **localhost**.
4. Click **Apply**.

Your sites will run cleanly via `http://localhost:<port>` without requiring host file edits.

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE). LocalWP itself is a proprietary product owned by Flywheel / WPEngine.
