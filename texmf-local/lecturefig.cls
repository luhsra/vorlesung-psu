\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{lecturefig}[2019/07/01 The Lecture Figure Class]  % YYYY/MM/DD

\IfFileExists{luatex85.sty}{\RequirePackage{luatex85}}{}
\LoadClass{beamer}

\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{beamertools}
\RequirePackage[active,tightpage]{preview}
\RequirePackage{wasysym}
\RequirePackage{marvosym}

\RequirePackage{tikz}

\PreviewEnvironment{tikzpicture}
  \usetikzlibrary{
    calc,
    fit,
    decorations.pathreplacing,
    backgrounds,
    decorations.text,
    shapes,
    shapes.misc,
    shapes.geometric,
    positioning,
    tikzmark,
    matrix,
    arrows,
    arrows.meta,
    sra
  }
  \pgfdeclarelayer{background2}
  \pgfdeclarelayer{background}
  \pgfdeclarelayer{foreground}
  \pgfsetlayers{background2,background,main,foreground}


\RequirePackage{sra-color}

\RequirePackage{pgffor}


\tikzset{
  >=Stealth,
  tikz on layer/.style 2 args={
    append after command={
      \pgfextra{%
        \begin{pgfinterruptpath}
          \begin{pgfonlayer}{#1}
            #2
          \end{pgfonlayer}
        \end{pgfinterruptpath}
      }%
    }
  },
}
