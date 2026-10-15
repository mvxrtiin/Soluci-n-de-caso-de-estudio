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

procesar_flujo([], _, _, [], []).

procesar_flujo([Solicitud | Resto], Salas, Ocupadas, Aceptadas, Rechazadas) :-
    evaluar_solicitud(Solicitud, Salas, Ocupadas, Resultado),
    actualizar_estado(Solicitud, Resultado, Ocupadas, NuevasOcupadas, Aceptadas, AcResto, Rechazadas, RchResto),
    procesar_flujo(Resto, Salas, NuevasOcupadas, AcResto, RchResto).

actualizar_estado(solicitud(IdSol, Franja, _, _), aceptada(Sala), Ocupadas, [ocupada(Sala, Franja) | Ocupadas], [asignada(IdSol, Sala, Franja) | AcResto], AcResto, Rechazadas, Rechazadas).

actualizar_estado(solicitud(IdSol, Franja, _, _), rechazada(Motivo), Ocupadas, Ocupadas, Aceptadas, Aceptadas, [rechazo(IdSol, Franja, Motivo) | RchResto], RchResto).

evaluar_solicitud(solicitud(_, Franja, Asistentes, EqReq), Salas, Ocupadas, aceptada(IdSala)) :-
    member(sala(IdSala, CapSala, EqSala), Salas),
    Asistentes =< CapSala,
    incluye_equipamiento(EqReq, EqSala),
    \+ member(ocupada(IdSala, Franja), Ocupadas).

evaluar_solicitud(_, _, _, rechazada('No cumple requisitos')).

incluye_equipamiento([], _).

incluye_equipamiento([Item | Resto], EqSala) :-
    member(Item, EqSala),
    incluye_equipamiento(Resto, EqSala).
