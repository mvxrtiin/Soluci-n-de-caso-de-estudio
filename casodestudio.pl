catalogo_salas([
    sala(s101, 20, [proyector, pizarra]),
    sala(s102, 40, [proyector, pizarra, audio]),
    sala(s103, 15, [pizarra]),
    sala(lab1, 30, [proyector, pizarra, computadores, red])
]).

flujo_solicitudes([
    solicitud(req1, '08:30-10:00', 18, [proyector, pizarra]),
    solicitud(req2, '08:30-10:00', 25, [proyector, audio]),
    solicitud(req3, '08:30-10:00', 15, [proyector])
]).

procesar_flujo([Solicitud | Resto], Salas, Asignaciones) :-
    evaluar_solicitud(Solicitud, Salas, Asignacion),
    procesar_flujo(Resto, Salas, Asignaciones).

evaluar_solicitud(solicitud(IdSol, Franja, Asistentes, EqReq), Salas, asignada(IdSol, IdSala)) :-
    member(sala(IdSala, CapSala, EqSala), Salas).
