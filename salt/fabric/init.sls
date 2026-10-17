# =============================================================================
#  state: fabric   -  render the full intended config and REPLACE the running one
#
#  ALWAYS preview first (EOS computes the diff in a config session, nothing changes):
#     salt leaf3 state.apply fabric test=True
#  Then apply, one switch at a time:
#     salt leaf3 state.apply fabric
#
#  replace: True  = the switch ends up EXACTLY as the template says (removes drift).
#  The commit is atomic (EOS config session): all lines apply, or none do.
# =============================================================================
{%- set dev = pillar['fabric']['devices'][pillar['hostname']] %}
{%- set tpl = 'spine' if dev.role == 'spine' else 'leaf' %}

fabric_config:
  netconfig.managed:
    - template_name: salt://fabric/templates/{{ tpl }}.j2
    - replace: True
    - debug: False
