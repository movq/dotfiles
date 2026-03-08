{ config, lib, pkgs, ... }:

{
  imports = [
    ./dns.nix
  ];

  boot.initrd.availableKernelModules = [ "nvme" "ahci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c2785634-d1f7-4195-aedc-a7b372483f9f";
      fsType = "btrfs";
      options = [ "subvol=/nixos" "compress-force=zstd:3" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/75bdb730-422a-41b9-bf6f-b4953e610e23";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/c2785634-d1f7-4195-aedc-a7b372483f9f";
      fsType = "btrfs";
      options = [ "subvol=/home" "compress-force=zstd:3" ];
    };

  fileSystems."/mnt/rootvol" =
    { device = "/dev/disk/by-uuid/c2785634-d1f7-4195-aedc-a7b372483f9f";
      fsType = "btrfs";
      options = [ "subvol=/" "compress-force=zstd:3" ];
    };

  swapDevices = [ ];

  networking = {
    hostName = "fsn1-2";
    useDHCP = false;

    interfaces.enp35s0 = {
      ipv4.addresses = [{
        address = "135.181.178.34";
        prefixLength = 26;
      }];
      ipv6.addresses = [{
        address = "2a01:4f9:3a:201f::1";
        prefixLength = 64;
      }];
    };

    defaultGateway = {
      address = "135.181.178.1";
      interface = "enp35s0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp35s0";
    };

    nameservers = [ "185.12.64.1" "185.12.64.2" "2a01:4ff:ff00::add:1" "2a01:4ff:ff00::add:2" ];
  };
  networking.firewall.allowedTCPPorts = [ 53 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  time.timeZone = "Europe/London";

  users.extraGroups.mike.gid = 1000;
  users.users.mike = {
    isNormalUser = true;
    uid = 1000;
    group = "mike";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  security.sudo.wheelNeedsPassword = false;
  security.doas.enable = true;
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    keepEnv = true;
    noPass = true;
  }];

  services.openssh = {
    enable = true;
  };

  services.nginx = {
    enable = true;
    logError = "/var/log/nginx/error.log warn";
    additionalModules = [
      {
        name = "aws-auth";
        src = pkgs.fetchFromGitHub {
          owner = "kaltura";
          repo = "nginx-aws-auth-module";
          rev = "3664fc714d7b3903ed3aef2b3a0f2664ccee2842";
          hash = "sha256-d4m/NQRN6mVDlEhSLKOmuZedDkRi3KZO+RHxrcHPr2c=";
        };
        meta = {
          description = "Proxy to authenticated AWS services";
          homepage = "https://github.com/kaltura/nginx-aws-auth-module";
          license = with lib.licenses; [ agpl3Only ];
        };
      }
    ];

    config = ''
      worker_processes auto;
      pcre_jit on;

      events {
          worker_connections 1024;
      }

      http {
          include ${pkgs.mailcap}/etc/nginx/mime.types;
          default_type application/octet-stream;

          server_tokens off;
          client_max_body_size 1m;

          sendfile on;
          tcp_nopush on;

          ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
          ssl_dhparam /etc/ssl/nginx/dh2048.pem;
          ssl_prefer_server_ciphers on;
          ssl_session_cache shared:SSL:2m;
          ssl_session_timeout 1h;
          ssl_session_tickets off;

          gzip_vary on;

          map $http_upgrade $connection_upgrade {
              default upgrade;
              "" close;
          }

          log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for"';

          access_log off;

          server {
              listen 80 default_server;
              listen [::]:80 default_server;

              location / {
                  return 404;
              }
              location = /404.html {
                  internal;
              }
          }

          server {
              listen 443 ssl default_server;
              listen [::]:443 ssl default_server;

              ssl_certificate /etc/ssl/certs/selfsigned.crt;
              ssl_certificate_key /etc/ssl/private/selfsigned.key;

              location / {
                  return 404;
              }
              location = /404.html {
                  internal;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name ilmarin.net;

              ssl_certificate /var/lib/uacme/ilmarin.net/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/ilmarin.net/key.pem;

              location /.well-known/webfinger {
                  add_header Access-Control-Allow-Origin '*';
                  return 301 https://mst.ilmarin.net$request_uri;
              }

              location / {
                  return 404;
              }
              location = /404.html {
                  internal;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name vw.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              location / {
                  proxy_pass http://127.0.0.1:8000;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              root /srv/mjones.io;

              location = /.well-known/matrix/server {
                  add_header 'Access-Control-Allow-Origin' '*';
                  alias /srv/mjones.io/.well-known/matrix/server;
                  default_type application/json;
              }

              location = /.well-known/matrix/client {
                  add_header 'Access-Control-Allow-Origin' '*';
                  add_header Content-Type application/json;
                  return 200 '{"m.homeserver": {"base_url": "https://mtrx.mjones.io"}}';
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;
              http2 on;

              server_name mtrx.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              location /xhttp/ {
                  client_max_body_size 0;
                  grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  client_body_timeout 5m;
                  grpc_read_timeout 315;
                  grpc_send_timeout 5m;
                  grpc_pass unix:/tmp/xrxh.socket;
              }

              location ~ ^/_matrix/client/(.*)/(login|logout|refresh) {
                  proxy_http_version 1.1;
                  proxy_pass http://127.0.0.1:8081;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              }

              location / {
                  proxy_pass http://127.0.0.1:8008;
                  proxy_set_header X-Forwarded-For $remote_addr;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Host $host:$server_port;
                  client_max_body_size 500M;
                  client_body_buffer_size 500M;
                  proxy_http_version 1.1;
                  proxy_read_timeout 180s;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name mtrx-auth.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              location / {
                  proxy_pass http://[::1]:8081;
                  proxy_set_header X-Forwarded-For $remote_addr;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Host $host:$server_port;
                  proxy_http_version 1.1;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name element.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              root /srv/element;
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name cinny.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              location / {
                  root /srv/cinny;
                  rewrite ^/config.json$ /config.json break;
                  rewrite ^/manifest.json$ /manifest.json break;

                  rewrite ^/sw.js$ /sw.js break;
                  rewrite ^/pdf.worker.min.js$ /pdf.worker.min.js break;

                  rewrite ^/public/(.*)$ /public/$1 break;
                  rewrite ^/assets/(.*)$ /assets/$1 break;

                  rewrite ^(.+)$ /index.html break;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name git.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              location / {
                  proxy_pass http://127.0.0.1:3000;
                  proxy_set_header X-Forwarded-For $remote_addr;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Host $host:$server_port;
                  proxy_http_version 1.1;
                  client_max_body_size 10G;
                  proxy_send_timeout 1800s;
                  proxy_read_timeout 1800s;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              server_name ntfy.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              location / {
                  proxy_pass http://127.0.0.1:8080;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Host $host:$server_port;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "upgrade";
                  proxy_http_version 1.1;

                  proxy_buffering off;
                  proxy_request_buffering off;
                  proxy_redirect off;

                  proxy_connect_timeout 3m;
                  proxy_send_timeout 3m;
                  proxy_read_timeout 3m;

                  client_max_body_size 0;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              server_name webmail.mjones.io;

              root /srv/roundcube/public_html;
              index index.php;

              location / {
                  try_files $uri $uri/ /index.php?$query_string;
              }

              location ~ \.php$ {
                  try_files $uri =404;
                  include ${pkgs.nginxStable}/conf/fastcgi_params;
                  fastcgi_pass unix:/var/run/php-fpm84/php-fpm84.sock;
                  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                  fastcgi_index index.php;
              }

              location ~ /\.ht {
                  deny all;
              }
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;
              http2 on;

              server_name mst.ilmarin.net;

              ssl_certificate /var/lib/uacme/ilmarin.net/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/ilmarin.net/key.pem;

              access_log /var/log/nginx/access.log main;
              location ^~ /api/v1/streaming {
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Proxy "";

                  proxy_pass http://127.0.0.1:4000;
                  proxy_buffering off;
                  proxy_redirect off;
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection $connection_upgrade;
                  proxy_max_temp_file_size 0;

                  tcp_nodelay on;
              }

              location / {
                  proxy_pass http://127.0.0.1:3001;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header Host $host;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "upgrade";
                  proxy_http_version 1.1;
                  client_max_body_size 50m;
                  proxy_max_temp_file_size 0;
              }
          }

          aws_auth $r2_token {
              # /var/lib/nginx-secrets/r2-aws-auth.conf:
              # access_key <AWS_ACCESS_KEY>;
              # secret_key <AWS_SECRET_KEY>;
              include /var/lib/nginx-secrets/r2-aws-auth.conf;
              service s3;
              region auto;
          }

          server {
              listen 443 ssl;
              listen [::]:443 ssl;
              http2 on;

              server_name nix-cache.mjones.io;

              ssl_certificate /var/lib/uacme/mjones.io/cert.pem;
              ssl_certificate_key /var/lib/uacme/private/mjones.io/key.pem;

              location / {
                  proxy_pass https://9e011fdf51909dd48b1bec6c36e18a97.r2.cloudflarestorage.com/nix-cache/;
                  proxy_set_header Authorization $r2_token;
                  proxy_set_header X-Amz-Date $aws_auth_date;
                  proxy_set_header X-Amz-Content-SHA256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;

                  proxy_ssl_server_name on;
                  proxy_ssl_name 9e011fdf51909dd48b1bec6c36e18a97.r2.cloudflarestorage.com;
                  proxy_intercept_errors on;
                  proxy_cache_valid 200 10m;
              }
          }
      }
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nginx-secrets 0750 root nginx - -"
  ];

  nix.settings = {
    substituters = lib.mkForce [ "https://nix-cache.mjones.io" ];
    trusted-public-keys = lib.mkForce [ "nix-cache.mjones.io:tOio4xRDNRMH4PfvWIS9lDa32ynJGZt1naEVDg5u+nU=" ];
    trusted-users = [ "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 6;
    keep-derivations = true;
  };

  system.stateVersion = "26.05";
}
