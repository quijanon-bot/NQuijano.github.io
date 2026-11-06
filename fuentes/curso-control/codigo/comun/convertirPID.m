function [K, Ti, Td] = convertirPID(K, Ti, Td, de, a)
% CONVERTIRPID  Convierte los parámetros de un PID entre las formas del curso.
%   [K, Ti, Td] = convertirPID(K, Ti, Td, 'serie', 'ideal')
%   [K, Ti, Td] = convertirPID(K, Ti, Td, 'ideal', 'serie')
%   [Kc, Ki, Kd] = convertirPID(Kc, Ti, Td, 'ideal', 'paralelo')
%   [Kc, Ti, Td] = convertirPID(Kc, Ki, Kd, 'paralelo', 'ideal')
%   Ideal:    Kc (1 + 1/(Ti s) + Td s)
%   Paralelo: Kc + Ki/s + Kd s
%   Serie:    Kc (1 + 1/(Ti s)) (1 + Td s)
%   La conversión ideal -> serie exige Ti >= 4 Td (ceros reales).
switch [de '>' a]
    case 'serie>ideal'
        [K, Ti, Td] = deal(K*(1 + Td/Ti), Ti + Td, Ti*Td/(Ti + Td));
    case 'ideal>serie'
        if Ti < 4*Td
            error('convertirPID:complejos', 'Ti < 4 Td: los ceros son complejos y no hay forma serie.');
        end
        r = sqrt(1 - 4*Td/Ti);
        [K, Ti, Td] = deal(K/2*(1 + r), Ti/2*(1 + r), Ti/2*(1 - r));
    case 'ideal>paralelo'
        [K, Ti, Td] = deal(K, K/Ti, K*Td);          % devuelve Kc, Ki, Kd
    case 'paralelo>ideal'
        [K, Ti, Td] = deal(K, K/Ti, Td/K);          % entra Kc, Ki, Kd
    otherwise
        error('convertirPID:forma', 'Formas válidas: ideal, paralelo, serie.');
end
end
