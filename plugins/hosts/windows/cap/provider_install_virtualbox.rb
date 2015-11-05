require "pathname"
require "tempfile"

require "vagrant/util/downloader"
require "vagrant/util/subprocess"

module VagrantPlugins
  module HostWindows
    module Cap
      class ProviderInstallVirtualBox
        # The URL to download VirtualBox is hardcoded so we can have a
        # known-good version to download.
        URL = "http://download.virtualbox.org/virtualbox/5.0.8/VirtualBox-5.0.8-103449-Win.exe".freeze
        VERSION = "5.0.8".freeze

        def self.provider_install_virtualbox(env)
          tf = Tempfile.new("vagrant")
          tf.close

          # Prefixed UI for prettiness
          ui = Vagrant::UI::Prefixed.new(env.ui, "")

          # Start by downloading the file using the standard mechanism
          ui.output(I18n.t(
            "vagrant.hosts.windows.virtualbox_install_download",
            version: VERSION))
          ui.detail(I18n.t(
            "vagrant.hosts.windows.virtualbox_install_detail"))
          dl = Vagrant::Util::Downloader.new(URL, tf.path, ui: ui)
          dl.download!

          # Launch it
          ui.output(I18n.t(
            "vagrant.hosts.windows.virtualbox_install_install"))
          ui.detail(I18n.t(
            "vagrant.hosts.windows.virtualbox_install_install_detail"))
          script = File.expand_path("../../scripts/install_virtualbox.ps1", __FILE__)
          result = Vagrant::Util::Powershell.execute(script, tf.path)
          if result.exit_code != 0
            raise Vagrant::Errors::ProviderInstallFailed,
              provider: "virtualbox",
              stdout: result.stdout,
              stderr: result.stderr
          end

          ui.success(I18n.t("vagrant.hosts.windows.virtualbox_install_success"))
        end
      end
    end
  end
end
