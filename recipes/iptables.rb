# frozen_string_literal: true

# iptables settings
# =================

include_recipe 'iptables'

file '/etc/iptables.d/prefix' do
  content <<~EOF
    -A INPUT -j FWR
EOF
  mode '0600'
  notifies :run, 'execute[rebuild-iptables]'
end

file '/etc/iptables.d/suffix' do
  content <<~EOF
    -A FWR -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with icmp-port-unreachable
    -A FWR -p udp -j REJECT --reject-with icmp-port-unreachable
EOF
  mode '0600'
  notifies :run, 'execute[rebuild-iptables]'
end

rules = []
node['sanitize']['accept_interfaces'].to_hash.each do |iface, allow|
  rules << "-i #{iface}" if allow
end

node['sanitize']['ports'].to_hash.each do |port, allows|
  dst_opt = case port
            when Integer then "--dport #{port}"
            when /[,:]/  then "-m multiport --dports #{port}"
            else              "--dport #{Socket.getservbyname(port.to_s)}"
            end

  Array(allows).map do |allow|
    next unless allow
    src_opt = case allow
              when true then ''
              else           "--src #{allow}"
              end
    rules << "-p tcp -m tcp #{dst_opt} #{src_opt}"
  end
end
rules.sort!

iptables_rule 'all_sanitize' do
  variables rules: rules
end

include_recipe 'sanitize::ip6tables' if node['sanitize']['ip6tables']
