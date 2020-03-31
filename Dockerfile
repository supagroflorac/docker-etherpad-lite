FROM etherpad/etherpad:latest

#TODO check and add ep_table_of_content 
ARG PLUGINS="ep_author_hover ep_countable ep_delete_empty_pads ep_font_color ep_headings2 ep_pads_stats ep_page_view ep_prompt_for_name ep_spellcheck ep_subscript_and_superscript ep_user_font_size ep_warn_too_much_chars ep_comments_page ep_delete_after_delay"

RUN for PLUGIN in ${PLUGINS}; do npm install "${PLUGIN}"; done

# Copy the configuration file.
COPY --chown=etherpad:etherpad ./settings.json.delete_after_delay /opt/etherpad-lite/settings.json.delete_after_delay

# And add ep_delete_after_delay configuration
RUN head -n -2 settings.json.docker > settings.json
RUN echo "}, // logfile \n" >> settings.json
RUN cat settings.json.delete_after_delay >> settings.json

RUN more settings.json

# Patch etherpad pour qu'il charge le fichier defaultpad.txt comme texte par défaut
RUN sed -i "s/exports.defaultPadText = .*/exports.defaultPadText = fs.readFileSync('defaultpad.txt', 'utf8')\;/" /opt/etherpad-lite/src/node/utils/Settings.js

# Supprime la ligne dans le fichier de config pour ne pas écraser le fichier chargé.
RUN sed -i "/\"defaultPadText\" :.*/d" settings.json

# Copy default pad content
COPY --chown=etherpad:etherpad ./defaultpad.txt /opt/etherpad-lite/defaultpad.txt
