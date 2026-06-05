{% set config = salt['omv_conf.get']('conf.service.ldap') %}

{% set ldap_config_file = salt['pillar.get']('default:OMV_LDAP_CONFIG', '/etc/ldap/ldap.conf') %}
{% set nslcd_config_file = salt['pillar.get']('default:OMV_LDAP_NSLCD_CONFIG', '/etc/nslcd.conf') %}
{% set sssd_config_file = salt['pillar.get']('default:OMV_LDAP_SSSD_CONFIG', '/etc/sssd/sssd.conf') %}

{% if config.enable | to_bool %}

configure_ldap_dir:
  file.directory:
    - name: "/etc/ldap"
    - user: "root"
    - group: "root"
    - mode: '0755'
    - makedirs: True

configure_ldap:
  file.managed:
    - name: {{ ldap_config_file }}
    - source:
      - salt://{{ tpldir }}/files/etc-ldap_conf.j2
    - template: jinja
    - context:
        config: {{ config | json }}
    - user: root
    - group: root
    - mode: '0644'

{% if config.backend == 'sssd' %}

stop_unused_nslcd_service:
  service.dead:
    - name: nslcd
    - enable: False

configure_sssd:
  file.managed:
    - name: {{ sssd_config_file }}
    - source:
      - salt://{{ tpldir }}/files/etc-sssd_conf.j2
    - template: jinja
    - context:
        config: {{ config | json }}
    - user: root
    - group: root
    - mode: '0600'
    - makedirs: True

start_sssd_service:
  service.running:
    - name: sssd
    - enable: True
    - watch:
      - file: configure_sssd

{% else %}

stop_unused_sssd_service:
  service.dead:
    - name: sssd
    - enable: False

configure_nslcd:
  file.managed:
    - name: {{ nslcd_config_file }}
    - source:
      - salt://{{ tpldir }}/files/etc-nslcd_conf.j2
    - template: jinja
    - context:
        config: {{ config | json }}
    - user: root
    - group: nslcd
    - mode: '0640'

start_nslcd_service:
  service.running:
    - name: nslcd
    - enable: True
    - watch:
      - file: configure_nslcd

{% endif %}

{% else %}

stop_nslcd_service:
  service.dead:
    - name: nslcd
    - enable: False

stop_sssd_service:
  service.dead:
    - name: sssd
    - enable: False

{% endif %}
