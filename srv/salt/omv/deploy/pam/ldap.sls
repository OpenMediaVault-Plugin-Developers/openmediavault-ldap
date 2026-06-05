{% set config = salt['omv_conf.get']('conf.service.ldap') %}

{% set pam_profile = 'sss' if config.backend == 'sssd' else 'ldap' %}
{% set other_profile = 'ldap' if config.backend == 'sssd' else 'sss' %}

remove_other_pam_profile:
  cmd.run:
    - name: "pam-auth-update --force --package --remove {{ other_profile }}"

configure_pam_ldap_trigger:
  cmd.run:
    {% if config.enable | to_bool and config.enablepam | to_bool %}
    - name: "pam-auth-update --force --package {{ pam_profile }}"
    {% else %}
    - name: "pam-auth-update --force --package --remove {{ pam_profile }}"
    {% endif %}
