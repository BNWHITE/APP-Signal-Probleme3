%% ========================================================================
%  SCHEMA_NUMERISATION.m - Schéma fonctionnel de la chaîne de numérisation
%  APP Signal - ISEP 2025-2026 - Problème III
%  ========================================================================
clear; close all; clc;

%% Schéma fonctionnel affiché en figure
figure('Name', 'Schéma fonctionnel de numérisation', ...
       'Position', [100, 100, 1200, 400], 'Color', 'w');

% Paramètres d'affichage
box_w = 0.12; box_h = 0.15;
y_center = 0.45;
arrow_y = y_center + box_h/2;

% --- Dessiner les blocs ---
blocks = {
    'Micro\n(idéal)', 0.02;
    'Filtre\nanti-repliement\n(passe-bas)', 0.18;
    'Échantillonneur\n(Bloquer-Ech.)', 0.38;
    'Quantificateur\n(CAN)', 0.58;
    'Codeur\nnumérique', 0.78
};

colors = [0.8 0.9 1.0;   % bleu clair
          0.9 1.0 0.8;   % vert clair
          1.0 0.9 0.8;   % orange clair
          1.0 0.8 0.8;   % rouge clair
          0.9 0.8 1.0];  % violet clair

hold on; axis off;
for i = 1:size(blocks, 1)
    x = blocks{i, 2};
    rectangle('Position', [x, y_center, box_w, box_h*2], ...
              'Curvature', 0.1, 'FaceColor', colors(i,:), ...
              'EdgeColor', 'k', 'LineWidth', 1.5);
    text(x + box_w/2, y_center + box_h, blocks{i,1}, ...
         'HorizontalAlignment', 'center', 'FontSize', 9, ...
         'FontWeight', 'bold', 'Interpreter', 'none');
end

% --- Dessiner les flèches ---
for i = 1:size(blocks, 1)-1
    x_start = blocks{i, 2} + box_w;
    x_end = blocks{i+1, 2};
    annotation('arrow', [x_start+0.01, x_end-0.01], ...
               [arrow_y, arrow_y], 'LineWidth', 2, 'Color', [0.3 0.3 0.3]);
end

% --- Ajouter les paramètres sous chaque bloc ---
params = {
    'Bande infinie\nSans bruit', 0.02;
    'fc = 20 kHz\nAmin ≥ 90 dB', 0.18;
    'Fe = 44.1 kHz\nTe = 22.7 µs', 0.38;
    'b = 16 bits\nq = 15.3 µV', 0.58;
    'Stéréo\n2 canaux', 0.78
};

for i = 1:size(params, 1)
    x = params{i, 2};
    text(x + box_w/2, y_center - 0.08, params{i,1}, ...
         'HorizontalAlignment', 'center', 'FontSize', 8, ...
         'Color', [0.3 0.3 0.3], 'FontStyle', 'italic', ...
         'Interpreter', 'none');
end

% --- Signaux entre les blocs ---
signals = {'x_c(t)', 'x_f(t)', 'x_e(nTe)', 'x_q(nTe)', 'Signal\nnumérique'};
for i = 1:length(signals)-1
    x_start = blocks{i, 2} + box_w;
    x_end = blocks{i+1, 2};
    x_mid = (x_start + x_end) / 2;
    text(x_mid, arrow_y + 0.08, signals{i}, ...
         'HorizontalAlignment', 'center', 'FontSize', 8, ...
         'Color', [0 0 0.7], 'Interpreter', 'none');
end

% Titre
text(0.5, 0.92, 'Schéma fonctionnel de la chaîne de numérisation - Problème III', ...
     'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');

% Sortie finale
text(0.78 + box_w + 0.03, arrow_y, 'Signal\nnumérique', ...
     'FontSize', 9, 'FontWeight', 'bold', 'Color', [0 0.5 0], ...
     'Interpreter', 'none');

% Sauvegarder
saveas(gcf, '../figures/schema_numerisation.png');
fprintf('Figure sauvegardée : ../figures/schema_numerisation.png\n');
