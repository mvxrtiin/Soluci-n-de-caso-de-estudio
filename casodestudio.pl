catalogo_salas([
    sala(s101, 20, [proyector, pizarra]),
    sala(s102, 40, [proyector, pizarra, audio]),
    sala(s103, 15, [pizarra]),
    sala(lab1, 30, [proyector, pizarra, computadores, red])
]).

flujo_solicitudes([
    solicitud(req1, '08:30-10:00', 18, [proyector, pizarra]),
    solicitud(req2, '08:30-10:00', 25, [proyector, audio]),
    solicitud(req3, '08:30-10:00', 15, [proyector]),
    solicitud(req4, '08:30-10:00', 10, [proyector]),
    solicitud(req5, '10:15-11:45', 50, [pizarra]),
    solicitud(req6, '10:15-11:45', 20, [proyector, videoconferencia]),
    solicitud(req7, '10:15-11:45', 12, [pizarra])
]).

% Punto 1: Variables logicas
% Aqui no se modifica el valor de las variables que ya existen
% En su lugar, se arman las listas de salida conectando variables vacias paso a paso mientras avanza el programa
procesar_flujo([], _, _, [], []).

procesar_flujo([Solicitud | Resto], Salas, Ocupadas, Aceptadas, Rechazadas) :-
    evaluar_solicitud(Solicitud, Salas, Ocupadas, Resultado),
    actualizar_estado(Solicitud, Resultado, Ocupadas, NuevasOcupadas, Aceptadas, AcResto, Rechazadas, RchResto),
    procesar_flujo(Resto, Salas, NuevasOcupadas, AcResto, RchResto).

% Punto 2: Unificacion
% A diferencia de la programacion funcional, aqui se comparan patrones completos de datos
% para saber que camino tomar y asignar varias variables al mismo tiempo
actualizar_estado(solicitud(IdSol, Franja, _, _), aceptada(Sala), Ocupadas, [ocupada(Sala, Franja) | Ocupadas], [asignada(IdSol, Sala, Franja) | AcResto], AcResto, Rechazadas, Rechazadas).

actualizar_estado(solicitud(IdSol, Franja, _, _), rechazada(Motivo), Ocupadas, Ocupadas, Aceptadas, Aceptadas, [rechazo(IdSol, Franja, Motivo) | RchResto], RchResto).

% Punto 3: Determinismo
% Usamos el simbolo de corte para detener la busqueda apenas encontramos
% la primera sala que sirve o identificamos el motivo del rechazo
% Evita que el programa siga buscando opciones y asegura un unico camino
evaluar_solicitud(Solicitud, Salas, Ocupadas, aceptada(IdSala)) :-
    buscar_primera_sala(Salas, Solicitud, Ocupadas, IdSala), !.

evaluar_solicitud(Solicitud, Salas, Ocupadas, rechazada(Motivo)) :-
    diagnosticar_rechazo(Solicitud, Salas, Ocupadas, Motivo), !.

buscar_primera_sala([sala(IdSala, CapSala, EqSala) | _], solicitud(_, Franja, Asistentes, EqReq), Ocupadas, IdSala) :-
    Asistentes =< CapSala,
    incluye_equipamiento(EqReq, EqSala),
    \+ member(ocupada(IdSala, Franja), Ocupadas), !.

buscar_primera_sala([_ | RestoSalas], Solicitud, Ocupadas, IdSala) :-
    buscar_primera_sala(RestoSalas, Solicitud, Ocupadas, IdSala).

incluye_equipamiento([], _).

incluye_equipamiento([Item | Resto], EqSala) :-
    member(Item, EqSala), !,
    incluye_equipamiento(Resto, EqSala).

diagnosticar_rechazo(solicitud(_, _, Asistentes, _), Salas, _, 'Capacidad insuficiente en el catalogo') :-
    \+ existe_sala_con_capacidad(Salas, Asistentes), !.

diagnosticar_rechazo(solicitud(_, _, Asistentes, EqReq), Salas, _, 'Ninguna sala posee el equipamiento requerido') :-
    \+ existe_sala_con_cap_y_eq(Salas, Asistentes, EqReq), !.

diagnosticar_rechazo(_, _, _, 'Salas compatibles ocupadas en la franja horaria').

existe_sala_con_capacidad([sala(_, CapSala, _) | _], Asistentes) :-
    Asistentes =< CapSala, !.

existe_sala_con_capacidad([_ | Resto], Asistentes) :-
    existe_sala_con_capacidad(Resto, Asistentes).

existe_sala_con_cap_y_eq([sala(_, CapSala, EqSala) | _], Asistentes, EqReq) :-
    Asistentes =< CapSala,
    incluye_equipamiento(EqReq, EqSala), !.

existe_sala_con_cap_y_eq([_ | Resto], Asistentes, EqReq) :-
    existe_sala_con_cap_y_eq(Resto, Asistentes, EqReq).

ejecutar :-
    catalogo_salas(Salas),
    flujo_solicitudes(Solicitudes),
    procesar_flujo(Solicitudes, Salas, [], Aceptadas, Rechazadas),
    writeln('\n--- SOLICITUDES ACEPTADAS ---'),
    imprimir_aceptadas(Aceptadas),
    writeln('\n--- SOLICITUDES RECHAZADAS ---'),
    imprimir_rechazadas(Rechazadas),
    writeln('').

imprimir_aceptadas([]).
imprimir_aceptadas([asignada(IdSol, IdSala, Franja) | Resto]) :-
    format('  [OK] Solicitud ~w -> Sala ~w (~w)~n', [IdSol, IdSala, Franja]),
    imprimir_aceptadas(Resto).

imprimir_rechazadas([]).
imprimir_rechazadas([rechazo(IdSol, Franja, Motivo) | Resto]) :-
    format('  [X]  Solicitud ~w (~w) -> Rechazada: ~w~n', [IdSol, Franja, Motivo]),
    imprimir_rechazadas(Resto).
