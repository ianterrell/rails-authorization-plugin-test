namespace :authorized do
  desc "Test plugin import via Piston and Plugin install"
  task :test_imports => ['authorized:import:piston',
                        'authorized:import:plugin_install']

  namespace :import do
    desc "Import authorized plugin via Piston"
    task :piston do
      p ""
      output = `piston --version`
      if output.blank?
        p "You do not have Piston 1.9.4 installed."
        piston_install_instructions
      elsif output.split("\n").first != "Piston 1.9.4"
        p "You do not have the latest version of Piston installed."
        piston_install_instructions
      else
        `rm -rf vendor/plugins/rails-authorization-plugin`
        output = `piston import --force git://github.com/DocSavage/rails-authorization-plugin.git vendor/plugins/rails-authorization-plugin`
        check_import(output, "Piston")
      end
      p ""
    end

    desc "Import authorized plugin via Plugin install"
    task :plugin_install do
      p ""
      `rm -rf vendor/plugins/rails-authorization-plugin`
      output = `script/plugin install --force git://github.com/DocSavage/rails-authorization-plugin.git`
      check_import(output, "Plugin install")
      p ""
    end
  end
end

def piston_install_instructions
  p "Get the latest by running:"
  p "  git clone git://github.com/francois/piston.git"
  p "  cd piston"
  p "  rake gem"
  p "  sudo rake install_gem"
end

def check_import(output, import_type)
  if !File.exists?('./vendor/plugins/rails-authorization-plugin/README.rdoc')
    p "Plugin Import via #{import_type} failed."
    p "The file ./vendor/plugins/authorized/README.rdoc does not exist, either because of an import or directory structure problem."
    p "Console output from #{import_type}"
    output.split("\n").each { |line| p "  #{line}" }
  else
    p "Plugin Successfully Imported"
  end
end