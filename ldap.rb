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
        user = ldap.search(:base => treebase, :filter => filter).first
        email = (not user['mailRoutingAddress'].empty?) ? user.mailRoutingAddress.first : user.mail.first
        return email
      else
        #Failed to authenticate
        return false
      end
    end
  end
end