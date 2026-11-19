function [valor, terminal, direccion] = eventoODE(valor, terminal, direccion)
% EVENTOODE  Función de eventos de ode45 escrita en una sola línea:
%   opc = odeset('Events', @(t, x) eventoODE(x(2), 0, 0));
%   valor: la cantidad cuyo cruce por cero se detecta; terminal: 1 detiene la
%   integración; direccion: +1 solo de subida, -1 solo de bajada, 0 ambas.
%   Reemplaza a deal(valor, terminal, direccion), que falla en las versiones
%   recientes de MATLAB: ode45 llama primero a la función con una sola salida,
%   y deal exige tantas salidas como entradas.
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
end
