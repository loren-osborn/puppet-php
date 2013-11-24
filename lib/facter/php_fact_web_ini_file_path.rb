# The path to the php.ini file for apache appears to be the first null terminated string
# in the module binary after the null terminated string "PHP_CONFIG_FILE_PATH". This may
# or may not hold for other versions of php, so a sanity check to make sure that the
# directory is an existing file.
# The location of the module binary is obtained from the module's *php5*.load file
# included in Apache's config file determined from rules borrowed from
# example42/puppet-apache


apache_conf_path = '/etc/httpd/conf/httpd.conf'
if /Ubuntu|Debian|Mint/i.match(Facter.value("operatingsystem"))
	apache_conf_path = '/etc/apache2/apache2.conf'
elsif /SLES|OpenSuSE/i.match(Facter.value("operatingsystem"))
	apache_conf_path = '/etc/apache2/httpd.conf'
elsif Facter.value("operatingsystem") == 'freebsd'
	apache_conf_path = '/usr/local/etc/apache20/httpd.conf'
end

find_php_ini_path_shell_command =
	"if [ -f '" + apache_conf_path + "' ] ; then " +
		'ls -d $( ' +
			'grep -azA 1 ' +
				"'^PHP_CONFIG_FILE_PATH\$' " +
				'$( ' +
					"sed -e 's/\\s*\$//' -e 's/^.*\\s//' " +
						'$( ' +
							'ls -1 $( ' +
								"echo -n '" + apache_conf_path + "' | " +
									"sed -e 'sx/[^/]*\$xx' ; " +
								'echo -n / ; ' +
								"grep 'mod.*\\.load\$' '" + apache_conf_path + "' | " + 
									"sed -e 's/\\s*\$//' -e 's/^.*\\s//' " +
							') | ' +
								'grep php5 ' +
						') ' +
				') | ' +
					"tr '\\000' '\\012' | " +
					"grep '^/' " +
		') 2> /dev/null ; ' +
	'fi'


Facter.add("php_fact_web_ini_file_path") do
  setcode do
    result = nil
    begin
		result = Facter::Util::Resolution.exec(find_php_ini_path_shell_command) || nil
		if result
			result = (result + '/php.ini')
		end
	rescue
	end
    result
  end
end