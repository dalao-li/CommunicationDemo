#ifndef BSTLogger_H
#define BSTLogger_H

#include "CoreGlobal.h"

#include <QString>

namespace BSTLogger {
    /**
     * @brief debug输出调试信息
     */
    void HWA_CORE_EXPORT debug(const QString&);

    /**
     * @brief warning输出警告信息
     */
    void HWA_CORE_EXPORT warning(const QString&);

    /**
     * @brief error输出错误信息
     */
    void HWA_CORE_EXPORT error(const QString&);

    /**
     * @brief info输出一般信息
     */
    void HWA_CORE_EXPORT info(const QString&);

    /**
     * @brief log向日志模块打印日志信息
     * @param type日志类型0-debug,1-warning,3-error,4-information
     * @param text要打印的日志内容
     */
    void HWA_CORE_EXPORT log(int type, const QString&);
}

//#ifdef __cplusplus
//    }
//#endif

#endif // BSTLogger_H
