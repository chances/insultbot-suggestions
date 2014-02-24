require 'net/ldap'

module Insults
  class LDAP
    def self.authenticate(username, password)
      ldap_args = {
        :host => 'openldap.cat.pdx.edu',
        :port => 389,
        :encryption => :start_tls,
        :auth => {
          :username => "uid=#{username},ou=People,dc=cat,dc=pdx,dc=edu",
          :password => password,
          :method => :simple
        }
      }
      ldap = Net::LDAP.new(ldap_args)
      #Try to authenticate
      if ldap.bind
        #Success, get their email
        filter = Net::LDAP::Filter.eq("uid", username)
        treebase = "ou=People,dc=cat,dc=pdx,dc=edu"
        begin
          user = ldap.search(:base => treebase, :filter => filter).first
          #Ensure the person is a catzen
          return false unless user.pod.include?('cat')
          #Get their email
          email = (not user.mailRoutingAddress.empty?) ? user.mailRoutingAddress.first : user.mail.first
          return email
        rescue
          #Failed to authenticate
          return false
        end
      else
        #Failed to authenticate
        false
      end
    end
  end
end
