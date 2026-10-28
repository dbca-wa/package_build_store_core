# DBCA LibreOffice runtime environment.

export LIBREOFFICE_HOME="/opt/libreoffice"
export URE_BOOTSTRAP="vnd.sun.star.pathname:/opt/libreoffice/program/fundamentalrc"

case ":${PATH}:" in
    *:/opt/libreoffice/program:*)
        ;;
    *)
        export PATH="/opt/libreoffice/program:${PATH}"
        ;;
esac

case ":${PYTHONPATH:-}:" in
    *:/opt/libreoffice/program:*)
        ;;
    *)
        export PYTHONPATH="/opt/libreoffice/program${PYTHONPATH:+:${PYTHONPATH}}"
        ;;
esac

case ":${LD_LIBRARY_PATH:-}:" in
    *:/opt/libreoffice/program:*)
        ;;
    *)
        export LD_LIBRARY_PATH="/opt/libreoffice/program${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
        ;;
esac
