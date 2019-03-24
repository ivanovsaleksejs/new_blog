---
id: a-year-and-a-half-with-nixos
title: "A year and a half with NixOS"
author: Aleksejs Ivanovs
date: 2019-03-23-T01
display_date: 23.03.2019
tags: [functional, os, nixos, system]
desc_no_tags: "It's been a year and a half since I switched to NixOS as primary operating system on desktop and servers. I think I gathered enough experience and can share my impressions about this OS."
description: <p>It's been a year and a half since I switched to NixOS as primary operating system on desktop and servers. I think I gathered enough experience and can share my impressions about this OS.</p><p>I will try to not dive into technical details about how this OS and packaging manager works under the hood. I'm also not trying to be technically precize. My point is to share some overall information for people who want to try this OS for work.</p><br>
---
<br />
<h2>Background</h2>
<br />
<p>Previously I've tried several Linux distributives - RedHat, CentOS, Debian, \*buntu, Arch. All of them contained some flaws - some unique for distributive and some are common. One of the common flaws is absense of rollback feature. Some of distributives are bad in solving dependencies - they can easily overwrite some lib and break software that uses it. These distros are also bad in reproducing configuration - I don't remember how many times I've spent reinstalling ubuntu and making the same configuration all over again. I also started to study functional languages and became a fan of declarative part of functional programming. That's why, when I heard about a Linux distributive that is declarative, atomic, supports rollbacks and solves tons of problems I've decided to give it a try.</p>
<br />
<h2>Intro</h2>
<br />
<p>NixOS is a Linux based operating system build around nix package manager. Nix package manager is the declarative package manager that utilizes so called nix language. Nix language is simple, turing complete, functional language which is built specifically for Nix package manager. Nix package manager uses a declarative approach for OS configuration and the installation of packages.</p>
<p>If you are familiar with functional languages then you might know what is lambda or anonymous (or arrow) function. It is a function with no name that has two parts - arguments and function body that usually returns a value. All nix configuration files are in fact functions that return configurations. The format of lambda function in nix is <span class="code">{args}: {body}</span>.</p>
<p>The usual way to install NixOS is to create a <span class="code">.nix</span> file with a function written in nix that describes computer configuration, packages and services to install etc. A function in the <span class="code">.nix</span> file changes options of operating system. You can find a list of options <a  href="https://nixos.org/nixos/options.html" target="_blank">here</a>.</p>
<p>Let's take a look on example:</p>
<pre>{ config, pkgs, ... }:
{
  
  #imports go here
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)

  services = {
    sshd.enable = true;
    printing = {
      enable = true;
      drivers  = [
        pkgs.gutenprint
        pkgs.gutenprintBin
      ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
      allowPointToPoint = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bash
    wget
  ];
}</pre>
<p>The first line contains parameters that are passed by NixOS building tools when build process is initiated. As you can see in the next lines, you can split configuration file into several files and import them. Next, there's an option <span class="code">boot.loader.systemd-boot.enable</span>, which is set to true. It tells NixOS to enable a systemd-boot EFI boot manager. All child options can be nested in one parent option - see <span class="code">services</span> option. At the end, an option <span class="code">environment.systemPackages</span> tells NixOS to install packages on system level - these packages will be available to all users and will be automatically updated when you update system.</p>
<p>Usually you save this file as <span class="code">/etc/nixos/configuration.nix</span> and then execute command <span class="code">nixos-rebuild switch</span>. The <span class="code">switch</span> key tells NixOS to create a new user environment called generation and to switch to it. I will get back to generations later. The <span class="code">nixos-rebuild</span> tool also supports other useful keys - <span class="code">test</span> (creates temporary generation which exists until you restart or switch to other generation), <span class="code">build-vm</span> (creates QEMU virtual machine file using .nix file) etc.</p>
<p>Now let's consider that you have NixOS installed and you want to make changes - you want to install firefox. You just add firefox in the list of packages and run <span class="code">nixos-rebuild switch</span> again. In some seconds firefox will be available to use, and you'll have a new generation that contains firefox.</p>
<br />
<h2>Generations</h2>
<br />
<p>Generations can be considered as "versions" of your NixOS installation. Each time you rebuild a system, you create a new user environment, and the symlink to it is called generation. It contains an information about installed packages and services and configuration. When you run rebuild, a new generation is created and a GRUB entry appears. Thus, if something goes terribly wrong, you can always reboot and choose a previous generation in GRUB menu. In fact, if your system is not totally halted, you don't need to reboot - you can easily switch to a previous generation using <span class="code">nixos-rebuild switch --rollback</span>.</p>
<p>Usually generations don't occupy a lot of disk space - they are not virtual machines or containers, they just contain a collection of symlinks. But if you need to clean up old generations then you can use several utilities, one of which is <span class="code">nix-collect-garbage</span>.</p>
<br />
<h2>nix-env</h2>
<br />
<p><span class="code">nix-env</span> is a utility that allows you to make changes in generations. For example you can install a package the way you used to do it with other package managers - <span class="code">nix-env --install firefox</span>. This command won't save changes in your <span class="code">.nix</span> file, so if you want to have a system that can be reproduced on other machine it's better to update <span class="code">.nix</span> file and use <span class="code">nixos-rebuild</span> utility.</p>
<p><span class="code">nix-env</span> can also be used to switch between generations. <span class="code">nix-env --rollback</span> will switch to previous generation. To switch to a specific generation you can use <span class="code">nix-env --switch-generation 42</span> or <span class="code">nix-env -G 42</span>. You can see a list of generations with <span class="code">nix-env --list-generations</span>, delete generations with <span class="code">nix-env --delete-generations 42</span>.</p>
<br />
<h2>Nix Store</h2>
<br />
<p>Nix store is a directory (usually /nix/store) that contains informations about packages. Information about every package is stored in it's subdirectory whose name is built using a hash of a package file that contains info about package version, inputs etc. Thus, information about different versions of say firefox will be stored in different subdirectories of nix store. That means that you can have all possible versions of any software on your PC and they won't conflict with each other. It solves a problem when two different packages depend on different versions of the same lib. Some other distributives also offer solutions to this problem but they are usually not so general and don't guarantee solutions in all cases.</p>
<br />
<h2>Atomicity</h2>
<br />
<p>One of the most important features of NixOS is atomicity. When you rebuild your system it won't create a new generation and won't switch to it until rebuild process is finished without errors. The rebuild process is whole, atomic. This is guaranteed by the way how nix package manager installs packages. Packages stored in nix store are symlinked to "profiles" - entries that serve as a layer between user and generations. User can be linked to several profiles and several users can use one profile. Profile contains symlinks to installed packages. Specific generation merges symlinks from profiles linked to this generation. This approach gives multiple benefits. One of them is that you never need to reinstall your OS - just change .nix file and rebuild. You also get a huge freedom in different configurations. And also you can use different generations as different versions of NixOS.</p>
<br />
<h2>Nix-shell</h2>
<br />
<p>nix-shell is a very powerful utility. One of ways to use it is to create a virtual shell on top of your installation with some new packages temporarily installed. For example, if you don't have an acpi package you can run <span class="code">nix-shell -p acpi</span>. You will enter a shell that will have acpi installed. After doing something with acpi you just type <span class="code">exit</span> and you will get back to your usual shell where acpi is not available (technically it will be stored in nix store but symlink will be destroyed). It is very useful for one-time runs or for tests.</p>
<br />
<h2>Binary cache</h2>
<br />
<p>NixOS builds all open source packages from source but thanks to the fact that every package is described by it's package file (that contains version, repo address, inputs etc) there's no need to rebuild the same package for the same architecture. That's why nix uses binary cache - if some package was already built with specific inputs for specific architecture it will simply download a binary from cache. This saves a lot of time when rebuilding your system.</p>
<br />
<h2>Nixops</h2>
<br />
<p>Nixops is a useful (though, very fresh and misses a lot of features) tool that allows you to use the declarative approach of nix to configure and deploy remote machines, virtual machines etc. Aside from giving you all features of nix, it also gives you an option to share a server state to other people. Nixops guarantees reproducable builds and the option to rollback. Atomicity gives you next to zero downtime while rebuilding.</p>
<br />
<h2>Downsides</h2>
<br />
<p>NixOS community is not very big. While NixOS solves a lot of problems by design, package files should still be managed manually. While Debian or similar ecosystems have huge community and a long history of problem solving, NixOS only gains it's popularity and needs a lot of hard work to prepare as many packages as possible. Also, NixOS is not friendly for people who used to use GUI - there are no user friendly installers.</p>
<br />
<h2>My experience</h2>
<br />
<p>My first installation went very well. The problems that I faced during a period of using NixOS are mostly with problematic packages, unsolved dependencies, drivers etc. For example, I still cannot figure out how to install a wifi scanner on NixOS. Most of the problems I had I could solve with the help of very friendly people from #nixos channel on freenode IRC server. If you decide to try and install NixOS and face some problems do not hesitate to ask them for help. On your first install I would recommend a tutorial available in nixos homepage, especially if you use UEFI. Also make sure to read Nix Pills - a good and detailed intro into nix. Also you can always search for <span class="code">.nix</span> files on github for some ideas.</p>
<br />
