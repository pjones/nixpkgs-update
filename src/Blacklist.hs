{-# LANGUAGE OverloadedStrings #-}

module Blacklist
  ( packageName
  , content
  , srcUrl
  , attrPath
  , checkResult
  ) where

import Data.Foldable (find)
import Data.Text (Text)
import qualified Data.Text as T

srcUrl :: Text -> Maybe Text
srcUrl url = snd <$> find (\(isBlacklisted, _) -> isBlacklisted url) srcUrlList

srcUrlList :: [(Text -> Bool, Text)]
srcUrlList =
  [(("gnome" `T.isInfixOf`), "Packages from gnome are currently blacklisted.")]

attrPath :: Text -> Maybe Text
attrPath ap = snd <$> find (\(isBlacklisted, _) -> isBlacklisted ap) attrPathList

attrPathList :: [(Text -> Bool, Text)]
attrPathList =
  [ prefix "lua" "Packages for lua are currently blacklisted. https://github.com/NixOS/nixpkgs/pull/37501#issuecomment-375169646"
  , prefix "lxqt" "Packages for lxqt are currently blacklisted."
  , prefix
      "altcoins.bitcoin-xt"
      "nix-prefetch-url has infinite redirect https://github.com/NixOS/nix/issues/2225 remove after Nix upgrade that includes https://github.com/NixOS/nix/commit/b920b908578d68c7c80f1c1e89c42784693e18d5."
  , prefix
      "altcoins.bitcoin"
      "@roconnor asked for a blacklist on this until something can be done with GPG signatures https://github.com/NixOS/nixpkgs/commit/77f3ac7b7638b33ab198330eaabbd6e0a2e751a9"
  ]

packageName :: Text -> Maybe Text
packageName pn = snd <$> find (\(isBlacklisted, _) -> isBlacklisted pn) nameList

nameList :: [(Text -> Bool, Text)]
nameList =
  [ prefix "r-" "we don't know how to find the attrpath for these"
  , infixOf "jquery" "this isn't a real package"
  , infixOf "google-cloud-sdk" "complicated package"
  , infixOf "github-release" "complicated package"
  , infixOf
      "libxc"
      "currently people don't want to update this https://github.com/NixOS/nixpkgs/pull/35821"
  , infixOf "perl" "currently don't know how to update perl"
  , infixOf "python" "currently don't know how to update python"
  , infixOf "cdrtools" "We keep downgrading this by accident."
  , infixOf "gst" "gstreamer plugins are kept in lockstep."
  , infixOf "electron" "multi-platform srcs in file."
  , infixOf
      "linux-headers"
      "Not updated until many packages depend on it (part of stdenv)."
  , infixOf "xfce" "@volth asked to not update xfce"
  , infixOf "cmake-cursesUI-qt4UI" "Derivation file is complicated"
  , infixOf "iana-etc" "@mic92 takes care of this package"
  , infixOf
      "checkbashism"
      "needs to be fixed, see https://github.com/NixOS/nixpkgs/pull/39552"
  , eq "isl" "multi-version long building package"
  , infixOf "qscintilla" "https://github.com/ryantm/nixpkgs-update/issues/51"
  , eq "itstool" "https://github.com/NixOS/nixpkgs/pull/41339"
  , eq
      "wire-desktop"
      "nixpkgs-update cannot handle this derivation https://github.com/NixOS/nixpkgs/pull/42936#issuecomment-402282692"
  , infixOf
      "virtualbox"
      "nixpkgs-update cannot handle updating the guest additions https://github.com/NixOS/nixpkgs/pull/42934"
  ]

content :: [(Text, Text)]
content =
  [ ("DO NOT EDIT", "Derivation file says not to edit it.")
  , ("Do not edit!", "Derivation file says not to edit it.")
    -- Skip packages that have special builders
  , ("buildGoPackage", "Derivation contains buildGoPackage.")
  , ("buildRustCrate", "Derivation contains buildRustCrate.")
  , ("buildPythonPackage", "Derivation contains buildPythonPackage.")
  , ("buildRubyGem", "Derivation contains buildRubyGem.")
  , ("bundlerEnv", "Derivation contains bundlerEnv.")
  , ("buildPerlPackage", "Derivation contains buildPerlPackage.")
  ]

checkResult :: Text -> Maybe Text
checkResult pn =
  snd <$> find (\(isBlacklisted, _) -> isBlacklisted pn) checkResultList

checkResultList :: [(Text -> Bool, Text)]
checkResultList =
  [ infixOf
      "busybox"
      "- busybox result is not automatically checked, because some binaries kill the shell"
  , infixOf
      "fcitx"
      "- fcitx result is not automatically checked, because some binaries gets stuck in daemons"
  ]

prefix :: Text -> Text -> (Text -> Bool, Text)
prefix part reason = ((part `T.isPrefixOf`), reason)

infixOf :: Text -> Text -> (Text -> Bool, Text)
infixOf part reason = ((part `T.isInfixOf`), reason)

eq :: Text -> Text -> (Text -> Bool, Text)
eq part reason = ((part ==), reason)
