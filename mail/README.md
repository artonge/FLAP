# Mail module for FLAP

---

### Functionality

- Expose IMAP and SMTP server with STARTLS encryption.
- Allow users to receive mails to {username}@{any_domain}.
- Allow an admin user to send mails to the users mail addresses.
- Generate DKIM on domain names updates.
- SPAM protection with spamassassin and postscreen.

### Possible improvements

- Make SOGo-Postfix communication faster.
- Enable fail2ban. This should be share across all the services.
- Enable ClamAV. This is resource intensive, so extra care must be took to prevent overloading the FLAP box.
- Auto update DNS records. Complicated as we need to write code for each domain name providers.
- Expose the Sieve server ? I never used it, maybe it is a cool functionality.
