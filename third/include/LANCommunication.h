#ifndef LANCOMMUNICATION_H
#define LANCOMMUNICATION_H

#if defined(LANCOMMUNICATION_LIBRARY)
#  define LANCOMMUNICATIONSHARED_EXPORT __declspec(dllexport)
#else
#  define LANCOMMUNICATIONSHARED_EXPORT __declspec(dllimport)
#endif

#include <vector>
#include <functional>

/**
 * @brief 仿ASIO端点概念
 */
struct EndPoint
{
    std::string ip;
    unsigned short port;
};

typedef void DataCallBack(const EndPoint& ep,
                          void* data,
                          size_t size);
typedef void ConnectionCallback(const EndPoint ep);
typedef void ErrorHandler(const std::string&, int ec);

struct LANCommunicationPrivate;
/**
 * @brief 局域网通讯库，监听本地一个端口数据，当有数据和新连接进入后通过回调对外通知；\n
 *        连接远程，发送数据包，数据包要求最大32K字节;write为文件写入接口，最大4G
 */
class LANCOMMUNICATIONSHARED_EXPORT LANCommunication
{
public:
    LANCommunication();
    ~LANCommunication();

    LANCommunication(LANCommunication&& r);
    LANCommunication& operator=(LANCommunication&& r);

    /**
     * @brief hostName获取本地主机名称
     * @return 返回本地主机名称
     */
    std::string hostName() const;

    /**
     * @brief hostAddress4获取本地主机IP地址
     * @return 本地主机IP地址
     */
    std::vector<std::string> hostAddress4() const;

    void listen(unsigned short port);
    void bind(unsigned short port);

    /**
     * @brief write文件到ep端点
     * @param ep远程端点
     * @param file本地文件
     * @return 发送文件大小
     */
    std::size_t write(const EndPoint& ep, const std::string& file);

    /**
     * @brief send向远程ep发送TCP数据
     * @param ep端点
     * @param data数据
     * @param size数据大小
     * @return 返回发送字节数
     */
    std::size_t send(const EndPoint& ep,
                     void* data,
                     size_t size);

    /**
     * @brief send向远程ep发送UDP数据
     * @param ep端点
     * @param data数据
     * @param size数据大小
     */
    void sendto(const EndPoint& ep,
                     void* data,
                     size_t size);

    /**
     * @brief registerDataCall注册数据接收回调
     * @param call回调函数指针
     */
    void registerDataCall(const std::function<DataCallBack>& call);

    /**
     * @brief registerNewConnectionCall新连接回调
     * @param call回调函数指针
     */
    void registerNewConnectionCall(const std::function<ConnectionCallback>& call);

    /**
     * @brief registerEndConnectionCall连接断开回调
     * @param call回调函数指针
     */
    void registerEndConnectionCall(const std::function<ConnectionCallback>& call);

    /**
     * @brief 相同Ip主机可能有多个连接
     * @return 所有连接到本机的端点
     */
    std::vector<EndPoint> connections() const;

    /**
     * @brief ping通过ICMP协议查看远程是否可用
     * @param target目标主机ip地址
     * @return 返回值大于0表示可用；否则不可用
     */
    bool ping(const std::string& target);

private:
    LANCommunication(const LANCommunication&) = delete;
    LANCommunication& operator=(const LANCommunication&) = delete;

    bool connect(const EndPoint& ep);
    void disconnect(const EndPoint& ep);
    void restart();
    void reset();
    /**
     * @brief start启动本地服务
     */
    void start();
    void stop();
    int flag() const;
    inline bool finished(int flag) const { return (flag & 0x80000000) != 0; }

private:
    LANCommunicationPrivate* _p = nullptr;
};

#endif // LANCOMMUNICATION_H
