#ifndef CORE_GLOBAL_H
#define CORE_GLOBAL_H

#include <QtCore/qglobal.h>

#ifdef HWA_CORE_DLL
# define HWA_CORE_EXPORT Q_DECL_EXPORT
#else
# define HWA_CORE_EXPORT Q_DECL_IMPORT
#endif

#endif // CORE_GLOBAL_H
