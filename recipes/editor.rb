# frozen_string_literal: true

# Sane editor
# ===========

case node['platform_family']
when 'debian'
  package 'vim-nox'

  execute 'update-alternatives --set editor /usr/bin/vim.nox' do
    not_if do
      cmd = Mixlib::ShellOut.new('update-alternatives', '--query', 'editor')
      cmd.run_command
      cmd.error!
      cmd.stdout =~ %r{^Value:\s*/usr/bin/vim.nox$}
    end
  end
end
