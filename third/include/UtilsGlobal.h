#ifndef UTILS_GLOBAL_H
#define UTILS_GLOBAL_H

#include <QtCore/qglobal.h>

#ifdef HWA_UTILS_DLL
# define HWA_UTILS_EXPORT Q_DECL_EXPORT
#else
# define HWA_UTILS_EXPORT Q_DECL_IMPORT
#endif

#endif // CORE_GLOBAL_H
