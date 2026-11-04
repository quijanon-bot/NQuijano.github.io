%% =====================================================================
%%  apuntessisnl.cls -- Clase para las notas del curso
%%  Sistemas No Lineales (IELE 4311), Universidad de los Andes
%%  Nicanor Quijano -- versión piloto, noviembre de 2026
%%
%%  Derivada de apuntescontrol.cls (curso de Control): misma paleta, mismas
%%  cajas y misma lógica de código/sitio web, para que los dos cursos se lean
%%  igual. Agrega lo propio de un curso de matemáticas: teoremas, lemas,
%%  proposiciones y corolarios numerados con las definiciones, demostraciones
%%  y la caja "trampa" (conclusión plausible pero falsa).
%%
%%  Compilar con pdflatex (MacTeX / TeX Live completos):
%%      latexmk -pdf NotasSisNL.tex
%%  o:  pdflatex -> bibtex -> pdflatex -> pdflatex
%%
%%  Opciones de clase:
%%      borrador  : muestra las etiquetas \label en el margen (para editar)
%%      sinqr     : no imprime los códigos QR de los capítulos
%%
%%  Compatibilidad con los capítulos anteriores (mybook.cls): se definen
%%  mybox, mybox_ej, exbox, definition, rmk, \chapterwithquote y el estilo
%%  de listings "matlab", de modo que un capítulo viejo compila sin cambios
%%  mientras se migra al formato nuevo.
%% =====================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{apuntessisnl}[2026/11/04 Notas de Sistemas No Lineales]

\newif\ifsnl@borrador \snl@borradorfalse
\newif\ifsnl@qr       \snl@qrtrue
\DeclareOption{borrador}{\snl@borradortrue}
\DeclareOption{sinqr}{\snl@qrfalse}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\LoadClass[11pt,letterpaper,twoside,openany]{book}

%% ---------------------------------------------------------------------
%% Tipografía: Libertinus (texto y matemáticas), Lato (títulos y cajas),
%% Inconsolata (código).
%% ---------------------------------------------------------------------
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{libertinus}
\RequirePackage{libertinust1math}
\RequirePackage[defaultsans,scale=0.92]{lato}
\RequirePackage[varqu,scaled=0.95]{zi4}
\RequirePackage[spanish,es-noshorthands,es-tabla,es-nodecimaldot,es-nolists]{babel}
\RequirePackage{microtype}
\RequirePackage{csquotes}

%% ---------------------------------------------------------------------
%% Página: columna de texto + margen ancho para notas al margen
%% ---------------------------------------------------------------------
\RequirePackage[letterpaper,
  inner=2.0cm, textwidth=12.9cm,
  marginparsep=0.6cm, marginparwidth=4.8cm,
  top=2.5cm, bottom=2.5cm, headsep=0.9cm, footskip=1.2cm]{geometry}
\RequirePackage[strict]{changepage}
\newlength{\snl@extra}
\setlength{\snl@extra}{\dimexpr\marginparwidth+\marginparsep\relax}
%% Bloque a ancho completo (texto + margen), respeta páginas pares/impares
\newenvironment{anchocompleto}%
  {\begin{adjustwidth*}{}{-\snl@extra}}%
  {\end{adjustwidth*}}

%% ---------------------------------------------------------------------
%% Paquetes generales
%% ---------------------------------------------------------------------
\RequirePackage{amsmath,amssymb,mathtools,amsthm,bm}
\RequirePackage{graphicx}
\RequirePackage[dvipsnames,table]{xcolor}
\RequirePackage{tikz}
\usetikzlibrary{calc,positioning,arrows.meta,shapes.geometric,fadings,decorations.pathreplacing,decorations.pathmorphing}
\RequirePackage{booktabs,array,tabularx,multirow,longtable,xltabular}
\RequirePackage{enumitem}
\RequirePackage{float}
\RequirePackage{siunitx}
\sisetup{output-decimal-marker={.},group-separator={\,},group-minimum-digits=5}
\RequirePackage{etoolbox}
\RequirePackage{xparse}
\RequirePackage{fontawesome5}
\RequirePackage{qrcode}
\RequirePackage{pdfpages}
\RequirePackage{natbib}
\setcitestyle{numbers,square,sort&compress}
\RequirePackage{caption}
\RequirePackage[subrefformat=parens]{subcaption}
\RequirePackage{marginnote}
\RequirePackage{marginfix}
\RequirePackage{listings}
\RequirePackage[numbered,framed]{matlab-prettifier}
\RequirePackage[most]{tcolorbox}
\tcbuselibrary{listings}
\RequirePackage{titlesec}
\RequirePackage{fancyhdr}
\RequirePackage{emptypage}

%% ---------------------------------------------------------------------
%% Paleta del curso (la misma de las figuras y de la página web)
%% ---------------------------------------------------------------------
\definecolor{snlazul}{HTML}{1E5AA8}     % principal: definiciones, títulos
\definecolor{snlnoche}{HTML}{14213D}    % texto de títulos, código
\definecolor{snlvioleta}{HTML}{6C4AB6}  % ejemplos
\definecolor{snlcoral}{HTML}{D1495B}    % errores frecuentes
\definecolor{snlambar}{HTML}{E09F3E}    % historia
\definecolor{snlverde}{HTML}{2A9D8F}    % pausa activa
\definecolor{snlteal}{HTML}{0F7173}     % MATLAB / Simulink
\definecolor{snlgris}{HTML}{5C677D}     % texto secundario
\definecolor{snlfondo}{HTML}{F4F6FA}
%% Colores "viejos" (para que los capítulos anteriores compilen)
\definecolor{mygreen}{RGB}{28,172,0}
\definecolor{mylilas}{RGB}{170,55,241}
\definecolor{LightOcean}{RGB}{81,147,229}
\definecolor{DeepOcean}{RGB}{51,131,229}
\definecolor{BlueViolet}{RGB}{138,43,226}

%% Énfasis de color en el texto (reemplaza \textcolor{red}{...} y \textcolor{blue}{...})
\newcommand{\clave}[1]{\textcolor{snlazul}{\bfseries #1}}   % término que se define
\newcommand{\alerta}[1]{\textcolor{snlcoral}{#1}}           % afirmación importante

%% ---------------------------------------------------------------------
%% Enlaces y referencias cruzadas
%% ---------------------------------------------------------------------
\newcommand{\urlsitio}{https://USUARIO.github.io/curso-sisnl}
\newcommand{\urlrepo}{https://github.com/USUARIO/curso-sisnl}
\newcommand{\urlcodigo}{\urlrepo/blob/main/codigo}
%% \definirsitio{sitio}{repositorio}[ruta de los códigos, por defecto repositorio/blob/main/codigo]
\NewDocumentCommand{\definirsitio}{m m o}{\renewcommand{\urlsitio}{#1}\renewcommand{\urlrepo}{#2}%
  \IfValueT{#3}{\renewcommand{\urlcodigo}{#3}}}
\RequirePackage[hyphens]{url}
\RequirePackage{hyperref}
\hypersetup{colorlinks=true,linkcolor=snlazul,citecolor=snlverde,urlcolor=snlteal,
  pdfauthor={Nicanor Quijano},pdftitle={Notas de Sistemas No Lineales},
  bookmarksnumbered=true}
\RequirePackage[spanish,noabbrev,nameinlink]{cleveref}
\crefname{ejemplo}{ejemplo}{ejemplos}
\Crefname{ejemplo}{Ejemplo}{Ejemplos}
\crefname{definicion}{definición}{definiciones}
\crefname{problema}{problema}{problemas}
\crefname{lstlisting}{código}{códigos}
\crefname{trampa}{trampa}{trampas}
\Crefname{trampa}{Trampa}{Trampas}
\crefname{teorema}{teorema}{teoremas}
\Crefname{teorema}{Teorema}{Teoremas}
\crefname{lema}{lema}{lemas}
\Crefname{lema}{Lema}{Lemas}
\crefname{pausa}{pausa}{pausas}
\crefname{table}{tabla}{tablas}
\Crefname{table}{Tabla}{Tablas}
\crefname{chapter}{capítulo}{capítulos}
\Crefname{chapter}{Capítulo}{Capítulos}
\creflabelformat{equation}{#2(#1)#3}

\ifsnl@borrador
  \RequirePackage[color]{showkeys}
  \definecolor{refkey}{gray}{.6}\definecolor{labelkey}{gray}{.6}
\fi

%% ---------------------------------------------------------------------
%% Captions, notas al margen y figuras al margen
%% ---------------------------------------------------------------------
\captionsetup{font={small,sf},labelfont={bf,color=snlazul},labelsep=period,
  justification=justified,singlelinecheck=true}
\captionsetup[sub]{font={small,sf}}
\renewcommand{\figurename}{Figura}
\renewcommand{\tablename}{Tabla}
\renewcommand{\lstlistingname}{Código}
%% Nota al margen sin número, en sans pequeña y gris.
%% Fuera de cajas usa \marginpar (marginfix evita que se encimen);
%% dentro de una caja (modo interno) usa \marginnote.
\newcommand{\snl@margen}[1]{\ifinner\marginnote{#1}\else\marginpar{#1}\fi}
\newcommand{\notamargen}[1]{\snl@margen{\sffamily\footnotesize\color{snlgris}\raggedright #1}}
%% Nota numerada (referencias exactas, anécdotas): nota al pie
\newcommand{\nota}[1]{\footnote{#1}}
\setlength{\skip\footins}{14pt}

%% ---------------------------------------------------------------------
%% Encabezados y pies de página
%% ---------------------------------------------------------------------
\pagestyle{fancy}
\fancyhf{}
\fancyhfoffset[LO,RE]{0pt}
\fancyhfoffset[RO,LE]{\snl@extra}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\chaptermark}[1]{\markboth{#1}{}}
\renewcommand{\sectionmark}[1]{\markright{\thesection\quad #1}}
\fancyhead[LE]{\sffamily\small\bfseries\color{snlazul}\thepage\quad
  \mdseries\color{snlgris}\nouppercase{\leftmark}}
\fancyhead[RO]{\sffamily\small\color{snlgris}\nouppercase{\rightmark}\quad
  \bfseries\color{snlazul}\thepage}
\fancyfoot[RO,LE]{\sffamily\scriptsize\color{snlgris!70}%
  Sistemas No Lineales \textperiodcentered{} Uniandes}
\fancypagestyle{plain}{\fancyhf{}%
  \fancyfoot[RO,LE]{\sffamily\small\bfseries\color{snlazul}\thepage}}

%% ---------------------------------------------------------------------
%% Títulos de capítulo: franja de color con un retrato de fase de fondo
%% ---------------------------------------------------------------------
\newcommand{\snl@franja}[2]{% #1 = rótulo (Capítulo n), #2 = título
  \begin{tikzpicture}[remember picture,overlay]
    \fill[snlnoche] (current page.north west) rectangle ([yshift=-6.4cm]current page.north east);
    \fill[snlazul]  ([yshift=-6.4cm]current page.north west) rectangle ([yshift=-6.6cm]current page.north east);
    % Retrato de fase decorativo (firma visual del libro): conjuntos de
    % nivel de una V y una trayectoria que entra en espiral al equilibrio
    \begin{scope}[shift={([xshift=16.2cm,yshift=-3.3cm]current page.north west)},x=1cm,y=1cm]
      \clip (-16.2,3.3) rectangle (6,-3.1);
      \foreach \r in {0.6,1.2,...,6.0}{\draw[white,opacity=.08,line width=.8pt,rotate=-18] (0,0) ellipse ({1.35*\r} and {0.75*\r});}
      \draw[snlambar,opacity=.65,line width=1.4pt,rotate=-18]
        plot[domain=0:21,samples=260,smooth] ({4.6*exp(-0.115*\x)*cos(\x r)},{2.5*exp(-0.115*\x)*sin(\x r)});
      \fill[snlambar] (0,0) circle (2.2pt);
    \end{scope}
    \node[anchor=north west,text=snlambar,font=\sffamily\bfseries\large]
      at ([xshift=2.0cm,yshift=-1.4cm]current page.north west) {#1};
    \node[anchor=north west,text=white,font=\sffamily\bfseries\fontsize{26}{31}\selectfont,
          text width=15.5cm,align=left]
      at ([xshift=2.0cm,yshift=-2.15cm]current page.north west) {#2};
  \end{tikzpicture}}
\titleformat{\chapter}[block]{}{}{0pt}%
  {\snl@franja{\chaptertitlename~\thechapter}}
\titleformat{name=\chapter,numberless}[block]{}{}{0pt}%
  {\snl@franja{\ }}
\titlespacing*{\chapter}{0pt}{3.1cm}{0.6cm}
\addto\captionsspanish{\renewcommand{\chaptername}{Cap\'itulo}%
  \renewcommand{\appendixname}{Ap\'endice}%
  \renewcommand{\contentsname}{Contenido}%
  \renewcommand{\bibname}{Referencias}}
\renewcommand{\chaptertitlename}{\chaptername}
\apptocmd{\appendix}{\renewcommand{\chaptertitlename}{\appendixname}}{}{}

%% Secciones
\titleformat{\section}
  {\sffamily\Large\bfseries\color{snlnoche}}
  {\colorbox{snlazul}{\makebox[1.6em]{\color{white}\thesection}}}{0.6em}{}
\titleformat{\subsection}
  {\sffamily\large\bfseries\color{snlnoche}}{\color{snlazul}\thesubsection}{0.6em}{}
\titleformat{\subsubsection}
  {\sffamily\normalsize\bfseries\color{snlnoche}}{}{0em}{}
\titleformat{\paragraph}[runin]
  {\sffamily\normalsize\bfseries\color{snlazul}}{}{0em}{}[.]
\titlespacing*{\section}{0pt}{3.2ex plus 1ex minus .2ex}{1.6ex}
\titlespacing*{\subsection}{0pt}{2.6ex plus 1ex minus .2ex}{1.2ex}
\titlespacing*{\paragraph}{0pt}{1.6ex plus .5ex}{0.6em}
\setcounter{secnumdepth}{2}
\setcounter{tocdepth}{1}

%% Epígrafe (las citas literarias que abren cada capítulo)
\NewDocumentCommand{\epigrafe}{m m}{%
  \begin{flushright}\begin{minipage}{0.78\textwidth}\raggedleft
    \itshape\small\color{snlgris}#1\par\smallskip
    \upshape\sffamily\footnotesize\bfseries\color{snlnoche}--- #2
  \end{minipage}\end{flushright}\vspace{0.8em}}

%% Capítulo nuevo: \capitulo[etiqueta]{Título}{cita}{autor}
\NewDocumentCommand{\capitulo}{o m m m}{%
  \chapter{#2}\IfValueT{#1}{\label{#1}}\epigrafe{#3}{#4}}

%% Compatibilidad con mybook.cls: \chapterwithquote{Título}{cita \\ \\ autor}
\newcommand{\chapterwithquote}[2]{\chapter{#1}%
  \begin{flushright}\begin{minipage}{0.78\textwidth}\raggedleft
  \itshape\small\color{snlgris}#2\end{minipage}\end{flushright}\vspace{0.8em}}

%% ---------------------------------------------------------------------
%% Cajas pedagógicas (tcolorbox)
%% ---------------------------------------------------------------------
\tcbset{
  snl/.style={enhanced,breakable,boxrule=0pt,frame hidden,arc=1.5mm,
    left=3.2mm,right=3.2mm,top=2.2mm,bottom=2.2mm,
    before skip=1.1em,after skip=1.1em,
    fonttitle=\sffamily\bfseries\small,coltitle=#1,
    colback=#1!5,colframe=#1,
    borderline west={2.6pt}{0pt}{#1},
    attach title to upper,after title={\par\smallskip},
    title style={},
    parbox=false},
  snlsolido/.style={enhanced,breakable,arc=1.5mm,boxrule=0.6pt,
    colback=white,colframe=#1,colbacktitle=#1,coltitle=white,
    fonttitle=\sffamily\bfseries\small,left=3.2mm,right=3.2mm,
    before skip=1.1em,after skip=1.1em,parbox=false}
}
\newcommand{\snl@icono}[2]{{\color{#1}#2}\hspace{0.45em}}

%% Definición numerada:  \begin{definicion}{Respuesta en frecuencia} ...
\newtcolorbox[auto counter,number within=chapter,crefname={definición}{definiciones}]
  {definicion}[2][]{snl=snlazul,
  title={\snl@icono{snlazul}{\faBookOpen}Definición~\thetcbcounter\ifstrempty{#2}{}{: #2}},#1}

%% Lo esencial (idea clave, sin número)
\newtcolorbox{ideaclave}[1][]{snl=snlazul,colback=snlazul!9,
  title={\snl@icono{snlazul}{\faKey}Lo esencial},#1}

%% Ejemplo numerado con solución:  \begin{ejemplo}{Título} enunciado \solucion desarrollo \end{ejemplo}
\newtcolorbox[auto counter,number within=chapter,crefname={ejemplo}{ejemplos}]
  {ejemplo}[2][]{snl=snlvioleta,
  title={\snl@icono{snlvioleta}{\faPencil*}Ejemplo~\thetcbcounter\ifstrempty{#2}{}{: #2}},#1}
\newcommand{\solucion}{\par\smallskip{\color{snlvioleta!60}\hrule height .4pt}\smallskip
  \noindent{\sffamily\bfseries\small\color{snlvioleta}Soluci\'on.}\enspace}

%% Resultados matemáticos: comparten el contador de las definiciones
%% (Definición 11.3, Teorema 11.4, Lema 11.5, ...), como en Khalil.
%%   \begin{teorema}[label=thm:pa-xx]{Nombre (fuente)} ... \end{teorema}
\newtcolorbox[use counter from=definicion,crefname={teorema}{teoremas}]
  {teorema}[2][]{snl=snlazul,colback=snlazul!9,
  title={\snl@icono{snlazul}{\faCheckCircle}Teorema~\thetcbcounter\ifstrempty{#2}{}{: #2}},#1}
\newtcolorbox[use counter from=definicion,crefname={lema}{lemas}]
  {lema}[2][]{snl=snlazul,colback=snlazul!9,
  title={\snl@icono{snlazul}{\faCheckCircle}Lema~\thetcbcounter\ifstrempty{#2}{}{: #2}},#1}
\newtcolorbox[use counter from=definicion,crefname={proposición}{proposiciones}]
  {proposicion}[2][]{snl=snlazul,colback=snlazul!9,
  title={\snl@icono{snlazul}{\faCheckCircle}Proposición~\thetcbcounter\ifstrempty{#2}{}{: #2}},#1}
\newtcolorbox[use counter from=definicion,crefname={corolario}{corolarios}]
  {corolario}[2][]{snl=snlazul,colback=snlazul!9,
  title={\snl@icono{snlazul}{\faCheckCircle}Corolario~\thetcbcounter\ifstrempty{#2}{}{: #2}},#1}
%% Demostración (fuera de caja): "Demostración." ... cuadrado negro al final
\renewcommand{\qedsymbol}{\textcolor{snlazul}{$\blacksquare$}}
\RenewDocumentEnvironment{proof}{o}%
  {\par\smallskip\noindent{\sffamily\bfseries\small\color{snlazul}\IfValueTF{#1}{#1}{Demostraci\'on}.}\enspace}%
  {\hfill\qedsymbol\par\smallskip}
\newenvironment{demostracion}{\begin{proof}}{\end{proof}}

%% Trampa: la seña de identidad del curso. Una conclusión PLAUSIBLE pero
%% FALSA, por qué falla y cómo se razona bien. Numerada por capítulo.
%%   \begin{trampa}[label=tr:pa-xx]{Título corto}
%%     \plausible{afirmación}  explicación ...  \correcto{lo que sí vale}
%%   \end{trampa}
\newtcolorbox[auto counter,number within=chapter,crefname={trampa}{trampas}]
  {trampa}[2][]{snlsolido=snlcoral,colback=snlcoral!3,
  title={\faBug\hspace{0.45em}Trampa~\thetcbcounter\ifstrempty{#2}{}{: #2}},#1}
\newcommand{\plausible}[1]{\noindent{\sffamily\bfseries\small\color{snlcoral}Afirmaci\'on plausible.}\enspace\emph{#1}\par\smallskip}
\newcommand{\correcto}[1]{\par\smallskip\noindent{\sffamily\bfseries\small\color{snlverde}Lo correcto.}\enspace #1}

%% Error frecuente
\newtcolorbox{cuidado}[1][Error frecuente]{snl=snlcoral,
  title={\snl@icono{snlcoral}{\faExclamationTriangle}#1}}

%% Nota histórica (en el texto)
\newtcolorbox{historia}[1][Nota hist\'orica]{snl=snlambar,
  title={\snl@icono{snlambar}{\faLandmark}#1}}

%% Para profundizar (opcional, se marca con *)
\newtcolorbox{profundiza}[1][Para profundizar]{snl=snlgris,
  title={\snl@icono{snlgris}{\faLayerGroup}#1~(*)}}

%% Procedimiento / receta de diseño
\newtcolorbox{receta}[1][Procedimiento]{snlsolido=snlnoche,
  title={\faListOl\hspace{0.45em}#1}}

%% Pausa activa: preguntas cortas; las respuestas se acumulan para el final
\newcommand{\snl@respuestas}{}
\newtcolorbox[auto counter,number within=chapter]{pausa}[1][]{snl=snlverde,
  title={\snl@icono{snlverde}{\faPauseCircle}Pausa activa~\thetcbcounter},#1}
\NewDocumentCommand{\respuesta}{m}{%
  \xdef\snl@tmp{\thetcbcounter}%
  \expandafter\gappto\expandafter\snl@respuestas\expandafter{%
    \expandafter\item\expandafter[\expandafter{\expandafter\bfseries\snl@tmp}]#1}%
  \par\hfill{\sffamily\scriptsize\color{snlverde}\faArrowCircleDown\ respuesta al final del cap\'itulo}}
\newcommand{\respuestaspausas}{%
  \ifdefempty{\snl@respuestas}{}{%
  \section*{Respuestas a las pausas activas}
  \begin{description}[font=\sffamily\color{snlverde},leftmargin=3.2em,style=nextline]
  \snl@respuestas\end{description}}\gdef\snl@respuestas{}}

%% Objetivos del capítulo con QR a la página web
\NewDocumentEnvironment{objetivos}{O{}}%
  {\begin{tcolorbox}[enhanced,arc=1.5mm,boxrule=0pt,colback=snlfondo,
     left=4mm,right=4mm,top=3mm,bottom=3mm,
     title={\faFlagCheckered\hspace{0.5em}En este cap\'itulo},
     fonttitle=\sffamily\bfseries,coltitle=snlnoche,colbacktitle=snlfondo,
     attach title to upper,after title={\par\smallskip},
     overlay={\ifsnl@qr\ifstrempty{#1}{}{%
       \node[anchor=north east,inner sep=0pt] at ([xshift=\snl@extra,yshift=-1mm]frame.north east)
       {\begin{tabular}{@{}c@{}}\href{\urlsitio/#1}{\qrcode[height=2.3cm]{\urlsitio/#1}}\\[2pt]
        \sffamily\scriptsize\color{snlgris}c\'odigos, videos y\\
        \sffamily\scriptsize\color{snlgris}actividades en la web\end{tabular}};}\fi}]
   \sffamily\small Al terminar este cap\'itulo usted podr\'a:
   \begin{enumerate}[label=\textcolor{snlazul}{\bfseries\arabic*.},leftmargin=1.6em,itemsep=1pt,topsep=3pt]}%
  {\end{enumerate}\end{tcolorbox}}

%% Resumen final: "Para llevar"
\newtcolorbox{parallevar}[1][Para llevar]{snlsolido=snlazul,
  title={\faSuitcase\hspace{0.45em}#1}}

%% Problemas al final del capítulo
\newcounter{problema}[chapter]
\renewcommand{\theproblema}{\thechapter.\arabic{problema}}
\NewDocumentEnvironment{problema}{o}%
  {\par\medskip\refstepcounter{problema}%
   \noindent{\sffamily\bfseries\color{snlvioleta}Problema~\theproblema}%
   \IfValueT{#1}{\enspace{\sffamily\small\color{snlgris}(#1)}}\enspace}%
  {\par}
\newcommand{\etiquetaM}{\textsf{\small\bfseries\color{snlteal}[M]}}   % requiere MATLAB/Simulink
\newcommand{\etiquetaEstrella}{\textsf{\small\bfseries\color{snlgris}(*)}} % opcional

%% ---------------------------------------------------------------------
%% Código MATLAB
%% ---------------------------------------------------------------------
%% Los bloques de código salen DIRECTAMENTE de los archivos del repositorio
%% (carpeta ../codigo), así las notas y los códigos nunca se desincronizan.
%% Dentro de un .m se marca un fragmento con
%%     % [ini:nombre]
%%     ...
%%     % [fin:nombre]
\newcommand{\rutacodigo}{../codigo/}
\lstdefinestyle{snlmatlab}{style=Matlab-editor,
  basicstyle=\ttfamily\footnotesize,
  numbers=left,numberstyle={\tiny\color{snlgris!70}\ttfamily},numbersep=6pt,
  frame=none,xleftmargin=0pt,breaklines=true,columns=fullflexible,keepspaces=true,
  showstringspaces=false,
  rangebeginprefix={\%\ [ini:},rangebeginsuffix={]},
  rangeendprefix={\%\ [fin:},rangeendsuffix={]},
  includerangemarker=false,
  extendedchars=true,inputencoding=utf8,
  literate={á}{{\'a}}1 {é}{{\'e}}1 {í}{{\'i}}1 {ó}{{\'o}}1 {ú}{{\'u}}1
           {Á}{{\'A}}1 {É}{{\'E}}1 {Í}{{\'I}}1 {Ó}{{\'O}}1 {Ú}{{\'U}}1
           {ñ}{{\~n}}1 {Ñ}{{\~N}}1 {ü}{{\"u}}1 {°}{{\textdegree}}1 {¿}{{?`}}1 {¡}{{!`}}1}
%% Estilo de compatibilidad para los capítulos anteriores
\lstdefinestyle{matlab}{style=snlmatlab}
\lstset{style=snlmatlab}
\tcbset{snlcodigo/.style={enhanced,breakable,arc=1.5mm,boxrule=0pt,
  colback=snlfondo,colbacktitle=snlteal,coltitle=white,
  fonttitle=\ttfamily\footnotesize,left=5mm,right=2mm,top=1mm,bottom=1mm,
  before skip=1em,after skip=1em,listing only,
  listing options={style=snlmatlab}}}

%% Código escrito en el .tex:  \begin{codigo}{archivo.m}  ...  \end{codigo}
\newtcblisting{codigo}[2][]{snlcodigo,
  title={\faCode\hspace{0.5em}#2},#1}

%% Código tomado del repositorio:
%%   \codigorepo{carpeta/archivo.m}{marca}{descripción}
%%   marca vacía = archivo completo
\newcommand{\snl@titulocodigo}[2]{% #1 ruta, #2 descripción
  \parbox{\linewidth}{\hypersetup{linkcolor=white,urlcolor=white}\raggedright{\sffamily\small\bfseries\faCode\hspace{0.5em}#2}\\[-1pt]
  {\ttfamily\scriptsize\href{\urlcodigo/#1}{\color{white!85!snlteal}\detokenize{#1}}}}}
\NewDocumentCommand{\codigorepo}{O{} m m m}{%
  \ifstrempty{#3}%
   {\tcbinputlisting{snlcodigo,listing file={\rutacodigo#2},
     title={\snl@titulocodigo{#2}{#4}},#1}}%
   {\tcbinputlisting{snlcodigo,listing file={\rutacodigo#2},
     listing options={style=snlmatlab,linerange={#3-#3}},
     title={\snl@titulocodigo{#2}{#4}},#1}}}

%% Caja Simulink (describe el modelo que construye un crearModelo_*.m)
\newtcolorbox{modelo}[1][]{snl=snlteal,
  title={\snl@icono{snlteal}{\faProjectDiagram}Simulink\ifstrempty{#1}{}{: \texttt{#1}}}}

%% Video al margen:  \video{V1_maquina_bode}{La máquina de Bode}
\newcommand{\video}[2]{\snl@margen{\sffamily\footnotesize\raggedright
  \href{\urlsitio/videos.html\##1}{\textcolor{snlcoral}{\Large\faPlayCircle}}\enspace
  \textbf{\color{snlnoche}Video}\\[1pt]
  {\color{snlgris}#2}\\[1pt]{\scriptsize\ttfamily\color{snlgris!80}\detokenize{#1}}}}
%% Script al margen:  \script{carpeta/archivo.m}
\newcommand{\script}[2][]{\snl@margen{\sffamily\footnotesize\raggedright
  \href{\urlcodigo/#2}{\textcolor{snlteal}{\Large\faFileCode}}\enspace
  \textbf{\color{snlnoche}C\'odigo}\ifstrempty{#1}{}{\\[1pt]{\color{snlgris}#1}}\\[1pt]
  {\scriptsize\ttfamily\color{snlgris!80}\detokenize{#2}}}}

%% ---------------------------------------------------------------------
%% Compatibilidad con mybook.cls (capítulos aún no migrados)
%% ---------------------------------------------------------------------
\newtcolorbox{mybox}[1][]{snl=snlazul,colback=snlazul!7,#1}
\newtcolorbox{mybox_ej}[1][]{snl=snlvioleta,#1}
\newtcolorbox{exbox}{snl=snlgris}
\theoremstyle{definition}
\newtheorem*{definition}{Definici\'on}
\newtheorem*{rmk}{Observaci\'on}
\newtheorem*{theorem}{Teorema}
%% (\diag se define en notacion.sty)

%% ---------------------------------------------------------------------
%% Listas y párrafos
%% ---------------------------------------------------------------------
\setlist[itemize]{label=\textcolor{snlazul}{\small\textbullet},leftmargin=1.4em,itemsep=2pt,topsep=4pt}
\setlist[enumerate]{leftmargin=1.6em,itemsep=2pt,topsep=4pt}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0.55em plus 0.2em minus 0.1em}
\renewcommand{\arraystretch}{1.15}
\graphicspath{{figuras/}{Figuras/}}

%% Portada sencilla (si no se usa un PDF de portada)
\newcommand{\portada}[3]{% #1 título, #2 autor, #3 fecha
  \begin{titlepage}
  \begin{tikzpicture}[remember picture,overlay]
    \fill[snlnoche] (current page.north west) rectangle (current page.south east);
    \begin{scope}[shift={([xshift=13cm,yshift=-15cm]current page.north west)},x=1cm,y=1cm]
      \foreach \r in {0.8,1.6,...,9.6}{\draw[white,opacity=.07,line width=1pt,rotate=-18] (0,0) ellipse ({1.35*\r} and {0.75*\r});}
      \draw[snlambar,line width=2pt,rotate=-18]
        plot[domain=0:24,samples=320,smooth] ({8.5*exp(-0.11*\x)*cos(\x r)},{4.6*exp(-0.11*\x)*sin(\x r)});
      \fill[snlambar] (0,0) circle (3pt);
    \end{scope}
    \node[anchor=north west,text=snlambar,font=\sffamily\bfseries\Large]
      at ([xshift=2cm,yshift=-3cm]current page.north west) {IELE 4311 \textperiodcentered{} Universidad de los Andes};
    \node[anchor=north west,text=white,font=\sffamily\bfseries\fontsize{40}{46}\selectfont,text width=17cm]
      at ([xshift=2cm,yshift=-4.2cm]current page.north west) {#1};
    \node[anchor=south west,text=white,font=\sffamily\Large,text width=17cm]
      at ([xshift=2cm,yshift=4cm]current page.south west) {#2\\[4pt]{\large\color{white!70} #3}};
  \end{tikzpicture}
  \end{titlepage}}

\endinput
