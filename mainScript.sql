--- Création des types
CREATE TYPE bureau_type;
CREATE TYPE local_type AS OBJECT (local REF bureau_type);
CREATE TYPE locaux_type AS TABLE OF local_type;
CREATE TYPE segment1_type AS OBJECT (ind_IP VARCHAR2(11), longueur NUMBER, locaux locaux_type) ;
CREATE TYPE seg_type AS OBJECT (seg REF segment1_type);
CREATE TYPE segs_type AS TABLE OF seg_type;
CREATE TYPE poste_travail_type ;
CREATE TYPE eqpt_type AS OBJECT (eqpt REF poste_travail_type);
CREATE TYPE eqpts_type AS TABLE OF eqpt_type;
CREATE OR REPLACE TYPE bureau_type AS OBJECT (nbureau VARCHAR2(5), capacite NUMBER, etage NUMBER, segs segs_type, eqpts eqpts_type);
CREATE OR REPLACE TYPE poste_travail_type AS OBJECT (nserie VARCHAR2(5), adresseIP VARCHAR2(3), typeposte VARCHAR2(8), connexion REF segment1_type, localisation REF bureau_type);
CREATE TYPE install_type AS OBJECT (dateinst DATE, poste REF poste_travail_type);
CREATE TYPE installs_type AS TABLE OF install_type;
CREATE TYPE logiciel_type AS OBJECT (codelogi VARCHAR2(5), nomlogi VARCHAR2(10), version VARCHAR2(10), dateachat DATE, typeOS VARCHAR2(8), installs installs_type);

---Création des tables
CREATE TABLE bureau OF bureau_type (CONSTRAINT pk_bureau PRIMARY KEY (nbureau)) NESTED TABLE segs STORE AS tabsegs, NESTED TABLE eqpts STORE AS tabeqpts;
CREATE TABLE segment1 OF segment1_type (CONSTRAINT pk_segment1 PRIMARY KEY (ind_IP)) NESTED TABLE locaux STORE AS tablocaux;
CREATE TABLE poste_travail OF poste_travail_type (CONSTRAINT pk_poste_travail PRIMARY KEY (nserie));
CREATE TABLE logiciel OF logiciel_type (CONSTRAINT pk_logiciel PRIMARY KEY (codelogi)) NESTED TABLE installs STORE AS tabinstalls;


---Chargement des données--

--Chargement de la table Bureau
INSERT INTO bureau VALUES ('b1', 4, 2, segs_type(), eqpts_type());
INSERT INTO bureau VALUES ('b2', 6, 2, segs_type(), eqpts_type());
INSERT INTO bureau VALUES ('b3', 5, 3, segs_type(), eqpts_type());
INSERT INTO bureau VALUES ('b4', 5, 3, segs_type(), eqpts_type());

--Chargement de la table segment1
INSERT INTO segment1 VALUES ('130.40.30', 25, locaux_type());
INSERT INTO segment1 VALUES ('130.40.31', 75, locaux_type());
INSERT INTO segment1 VALUES ('130.40.32', 40, locaux_type());

--Insertion dans la table imbriquée segs de bureau
INSERT INTO THE (SELECT b.segs FROM bureau b WHERE b.nbureau='b1') 
SELECT REF(s) FROM segment1 s WHERE s.ind_IP='130.40.30';
INSERT INTO THE (SELECT b.segs FROM bureau b WHERE b.nbureau='b2') 
SELECT REF(s) FROM segment1 s WHERE s.ind_IP='130.40.31';
INSERT INTO THE (SELECT b.segs FROM bureau b WHERE b.nbureau='b3') 
SELECT REF(s) FROM segment1 s WHERE s.ind_IP IN ('130.40.31', '130.40.32');
INSERT INTO THE (SELECT b.segs FROM bureau b WHERE b.nbureau='b4') 
SELECT REF(s) FROM segment1 s WHERE s.ind_IP IN ('130.40.30', '130.40.31', '130.40.32');

--Insertion dans la table imbriquée locaux de segment1
INSERT INTO THE (SELECT s.locaux FROM segment1 s WHERE s.ind_IP='130.40.30') 
SELECT REF(b) FROM bureau b WHERE b.nbureau IN ('b1', 'b4');
INSERT INTO THE (SELECT s.locaux FROM segment1 s WHERE s.ind_IP='130.40.31') 
SELECT REF(b) FROM bureau b WHERE b.nbureau IN ('b2', 'b3', 'b4');
INSERT INTO THE (SELECT s.locaux FROM segment1 s WHERE s.ind_IP='130.40.32') 
SELECT REF(b) FROM bureau b WHERE b.nbureau='b3';

--Chargement de la table poste_travail
INSERT INTO poste_travail pt SELECT 'p1', '01', 'WinXP', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.30' and b.nbureau='b1';
INSERT INTO poste_travail pt SELECT 'p2', '02', 'WinXP', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.30' and b.nbureau='b1';
INSERT INTO poste_travail pt SELECT 'p3', '03', 'WinNT', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.30' and b.nbureau='b1';
INSERT INTO poste_travail pt SELECT 'p4', '01', 'TX', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.31' and b.nbureau='b2';
INSERT INTO poste_travail pt SELECT 'p5', '02', 'UnixHP', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.31' and b.nbureau='b2';
INSERT INTO poste_travail pt SELECT 'p6', '01', 'WinNT', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.32' and b.nbureau='b3';
INSERT INTO poste_travail pt SELECT 'p7', '02', 'WinXP', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.32' and b.nbureau='b3';
INSERT INTO poste_travail pt SELECT 'p8', '03', 'WinXP', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.32' and b.nbureau='b3';
INSERT INTO poste_travail pt SELECT 'p9', '03', 'TX', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.31' and b.nbureau='b3';
INSERT INTO poste_travail pt SELECT 'p10', '04', 'TX', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.31' and b.nbureau='b4';
INSERT INTO poste_travail pt SELECT 'p11', '05', 'TX', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.31' and b.nbureau='b4';
INSERT INTO poste_travail pt SELECT 'p12', '04', 'WinXP', REF (s), REF (b) FROM segment1 s, bureau b WHERE s.ind_IP='130.40.30' and b.nbureau='b4';

--Insertion dans la table imbriquée eqpts de bureau
INSERT INTO THE (SELECT b.eqpts FROM bureau b WHERE b.nbureau='b1') 
SELECT REF(p) FROM poste_travail p WHERE p.nserie IN ('p1', 'p2', 'p3');
INSERT INTO THE (SELECT b.eqpts FROM bureau b WHERE b.nbureau='b2') 
SELECT REF(p) FROM poste_travail p WHERE p.nserie IN ('p4', 'p5');
INSERT INTO THE (SELECT b.eqpts FROM bureau b WHERE b.nbureau='b3') 
SELECT REF(p) FROM poste_travail p WHERE p.nserie IN ('p6', 'p7', 'p8', 'p9');
INSERT INTO THE (SELECT b.eqpts FROM bureau b WHERE b.nbureau='b4') 
SELECT REF(p) FROM poste_travail p WHERE p.nserie IN ('p10', 'p11', 'p12');

--Chargement de la table logiciel

INSERT INTO logiciel VALUES ('log1', 'Oracle7', '7.1.2', '13/05/95', 'UnixHP', installs_type());
INSERT INTO logiciel VALUES ('log2', 'Oracle7', '7.3.0', '15/06/96', 'WinNT', installs_type());
INSERT INTO logiciel VALUES ('log3', 'Oracle8', '8.0.1', '16/01/98', 'UnixHP', installs_type());
INSERT INTO logiciel VALUES ('log4', 'SQL-Server', '6.0', '13/05/97', 'WinNT', installs_type());
INSERT INTO logiciel VALUES ('log5', 'Word', '97', '13/05/97', 'Win95', installs_type());
INSERT INTO logiciel VALUES ('log6', 'Windows', '95', '13/05/95', 'Win95', installs_type());
INSERT INTO logiciel VALUES ('log7', 'Front Page', '97', '20/12/97', 'Win95', installs_type());
INSERT INTO logiciel VALUES ('log8', 'SQL*Net', '2.0.1', '13/05/95', 'UnixHP', installs_type());

---Insertion dans la table imbriquée installs de logiciel
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log1') 
SELECT '13/05/95', REF(p) FROM poste_travail p WHERE p.nserie='p5';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log2') 
SELECT '15/06/96', REF(p) FROM poste_travail p WHERE p.nserie='p6';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log3') 
SELECT '18/01/98', REF(p) FROM poste_travail p WHERE p.nserie='p5';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log4') 
SELECT '15/05/97', REF(p) FROM poste_travail p WHERE p.nserie='p3';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log5') 
SELECT '13/05/97', REF(p) FROM poste_travail p WHERE p.nserie='p7';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log5') 
SELECT '13/05/97', REF(p) FROM poste_travail p WHERE p.nserie='p8';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log5') 
SELECT '15/05/97', REF(p) FROM poste_travail p WHERE p.nserie='p12';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log6') 
SELECT '13/05/97', REF(p) FROM poste_travail p WHERE p.nserie='p7';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log6') 
SELECT '20/06/95', REF(p) FROM poste_travail p WHERE p.nserie='p1';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log6') 
SELECT '20/06/95', REF(p) FROM poste_travail p WHERE p.nserie='p2';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log6') 
SELECT '20/06/95', REF(p) FROM poste_travail p WHERE p.nserie='p8';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log6') 
SELECT '22/06/95', REF(p) FROM poste_travail p WHERE p.nserie='p12';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log7') 
SELECT '05/02/97', REF(p) FROM poste_travail p WHERE p.nserie='p12';
INSERT INTO THE (SELECT l.installs FROM logiciel l WHERE l.codelogi='log8') 
SELECT '15/05/95', REF(p) FROM poste_travail p WHERE p.nserie='p5';


-- REQUETES SQL 

--1-AFFICHAGE DE tous les postes de type Windows

SELECT nserie, typeposte FROM Poste_travail P
WHERE P.typeposte='WinXP' OR P.typeposte='WinNT'

SELECT P.connexion.Ind_ip||'.'||P.adresseip
FROM Poste_travail P

--2-Le numéro des segments qui parcourent à la fois les bureaux b3 et b4

SELECT q1.seg.ind_ip FROM the(
    SELECT b.segs FROM bureau b
    WHERE b.nbureau='b3') q1;
UNION
select q2.seg.ind_ip FROM the(
    SELECT b.segs FROM bureau b
    WHERE b.nbureau='b4') q2;
    
--3-Numéros et capacité des bureaux parcourus par le segment 130.40.32

SELECT q2.local.nbureau, q2.local.capacite FROM the(
    SELECT s.locaux FROM segment1 s
    WHERE s.ind_ip='130.40.32') q2;
  
--4-La liste des installations du logiciel log4.

SELECT l.dateinst, l.poste.nserie FROM the (
    SELECT a.installs FROM logiciel a 
    WHERE a.codelogi='log4'
) l;


--PARTIE 2 :

--1-Pour chaque logiciel, sa date d’installation :

SELECT l.codelogi, nt.dateinst, nt.poste.nserie
from logiciel l, the (
    SELECT a.installs FROM logiciel a 
    WHERE a.codelogi=l.codelogi
) nt;


--2-Pour chaque poste, le bureau dans lequel il est installé :

SELECT p.nserie, p.localisation.nbureau
FROM poste_travail p

--3-Donner le nombre d’installations de log5

SELECT count (*) FROM the (
    SELECT a.installs FROM logiciel a
    WHERE a.codelogi='log5'
)

--4-Donner la liste des logiciels installés depuis le 15/05/97

SELECT l.codelogi, nt.dateinst, nt.poste.nserie
FROM logiciel l, the (
    SELECT a.installs FROM logiciel a 
    WHERE a.codelogi=l.codelogi
) nt
WHERE nt.dateinst >= '15/05/97';

--5-Quels sont les logiciels installés sur plus de deux postes de travail

SELECT l.codelogi, count(nt.poste)
FROM logiciel l, the (
    SELECT a.installs FROM logiciel a 
    WHERE a.codelogi=l.codelogi
) nt
GROUP BY l.codelogi
HAVING count (nt.poste) > 2


--------------------------------------TP NO 3--------------------------------------

--6-Quels sont les postes installés à la fois dans les bureaux du 2eme et du 3ème étage

SELECT P.NSERIE, P.LOCALISATION.ETAGE AS ETAGE
FROM POSTE_TRAVAIL P
WHERE P.LOCALISATION.ETAGE=3 AND P.LOCALISATION.ETAGE=2

--7-Donner les listes des installations du logiciel log5 classés par date d’installations

SELECT L.CODELOGI, NT.DATEINST FROM  LOGICIEL L, THE(
    SELECT A.INSTALLS
    FROM LOGICIEL A
    WHERE A.CODELOGI=L.CODELOGI
) NT
WHERE L.CODELOGI='log5'
ORDER BY L.CODELOGI DESC

--8-Donner les noms des logiciels installés le jour de leur achat

SELECT L.NOMLOGI, L.DATEACHAT, NT.DATEINST FROM  LOGICIEL L, THE(
    SELECT A.INSTALLS
    FROM LOGICIEL A
    WHERE A.CODELOGI=L.CODELOGI
) NT
WHERE  NT.DATEINST=L.DATEACHAT

--9-Ecrire la requête permettant de déplacer le poste 1 au bureau b2
----------------------------------------------------------------------
-----------------------------AVANT UPDATE-----------------------------
----------------------------------------------------------------------
SELECT P.NSERIE, P.LOCALISATION.NBUREAU AS ETAGE
FROM POSTE_TRAVAIL P
WHERE P.NSERIE='p1'
----------------------------------------------------------------------
--------------------------------UPDATE--------------------------------
----------------------------------------------------------------------
UPDATE TABLE POSTE_TRAVAIL P
SET P.LOCALISATION.NBUREAU='b2'
WHERE P.NSERIE='p1'
----------------------------------------------------------------------
-----------------------------APRES UPDATE-----------------------------
----------------------------------------------------------------------
SELECT P.NSERIE, P.LOCALISATION.NBUREAU AS ETAGE
FROM POSTE_TRAVAIL P
WHERE P.NSERIE='p1'
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------