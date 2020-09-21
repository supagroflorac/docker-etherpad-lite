FROM etherpad/etherpad:1.8.4

USER root
RUN apt-get -y update \
	&& apt-get -y install abiword

USER etherpad

# Installation des plugin
#########################

# TODO check and add ep_table_of_content 
ARG PLUGINS="ep_author_hover ep_countable ep_delete_empty_pads ep_font_color ep_headings2 ep_pads_stats ep_page_view ep_prompt_for_name ep_spellcheck ep_subscript_and_superscript ep_user_font_size ep_warn_too_much_chars ep_delete_after_delay"
RUN for PLUGIN in ${PLUGINS}; \
	do npm install "${PLUGIN}"; \
	done

# Ajout de la configuration de ep_delete_after_delay
####################################################
COPY --chown=etherpad:etherpad ./settings.json /opt/etherpad-lite/settings.json

# Utilise le fichier defaultpad.txt comme contenu par défaut des pads.
######################################################################

# Patch etherpad pour qu'il charge le fichier defaultpad.txt comme texte par défaut
RUN sed -i "s/exports.defaultPadText = .*/exports.defaultPadText = fs.readFileSync('defaultpad.txt', 'utf8')\;/" /opt/etherpad-lite/src/node/utils/Settings.js

# Supprime la ligne dans le fichier de config pour ne pas écraser le fichier chargé.
RUN sed -i "/\"defaultPadText\" :.*/d" settings.json

# Ajoute le ficher defaultpad.txt
COPY --chown=etherpad:etherpad ./defaultpad.txt /opt/etherpad-lite/defaultpad.txt
