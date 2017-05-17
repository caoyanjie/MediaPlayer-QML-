#ifndef XMLPROCESS_H
#define XMLPROCESS_H

class QString;
class QDomDocument;
#include <QObject>
#include <QMap>
#include <QList>
#include <QString>
#include <QStringList>
class XmlProcess : public QObject
{
    Q_OBJECT
public:
//    struct{
//        QString name;
//        QString id;
//        QString parentName;
//        QMap<QString, QString> parentAttributes;
//        QStringList childrenNames;
//    };

    XmlProcess();

    // 初始化 xml 文件
    Q_INVOKABLE void initXmlFile();

    // 检测元素是否存在
    Q_INVOKABLE bool isElementExist(QString elementName);

    // 增加元素
    Q_INVOKABLE void addElement(QString parentName, QString elementName, QString attributeKey="", QString attributeValue="", QString elementText="");
    Q_INVOKABLE void addElement(QString parentName, QString elementName, QList<QMap<QString, QString> > attribute, QString elementText="");
    Q_INVOKABLE void addElementWithText(QString parentName, QString elementName, QString text);
    Q_INVOKABLE void addElements(QString parentName, QList<QMap<QString, QMap<QString, QString> > > children);
    Q_INVOKABLE void addRecursiveElement(QString parentNode, QString nodeName, QList<QMap<QString, QString> > attributes, QList<QMap<QString, QString> > children);
    Q_INVOKABLE void addRecursiveElement(QString parentName, QString parentAttributeKey, QString parentAttributeValue, QList<QMap<QString, QMap<QString, QString> > > selfNameAttributeKeyAndValue, QStringList childrenName, QList<QMap<QString, QString> > children);
    Q_INVOKABLE void addRecursiveElement(QString parentName, QList<QMap<QString, QMap<QString, QString> > > selfNameAttributeKeyAndValue, QStringList childrenNames, QList<QList<QString> > childrenText);
    //Q_INVOKABLE void addRecursiveElement(QString parentName, QList<QMap<QString, QList<QMap<QString, QString> > > > selfNameAndAttributes, QStringList childrenNames, QList<QList<QString> > childrenText);

    // 删除元素
    Q_INVOKABLE void removeElements(QString elementName);
    Q_INVOKABLE void removeElementByAttribute(QString elementName, QMap<QString, QString> attributeAndValue);
    Q_INVOKABLE void removeAllChildrenByAttribute(QString elementName, QString attributeKey, QString attributeValue);

    // 修改元素
    Q_INVOKABLE void alterElementText(QString parentName, QString selfName, QString text);
    Q_INVOKABLE void alterElementAttribute(QString elementName, QMap<QString, QString>attribute);
    Q_INVOKABLE void alterElementTextByAttribute(QString parentName, QMap<QString, QString>parentAttribute, QString elementName, QString text);

    // 获得数据
    Q_INVOKABLE QList<QMap<QString, QList<QMap<QString, QString> > > > getElementAttributeValueAndChildrenText(QString elementName, QStringList elementNames);
    Q_INVOKABLE QList<QMap<QString, QString> > getChildrenText(QString elementName, QStringList childrenNames);
//    QList<QStringList> getChildrenText(QString elementName, QStringList childrenNames);
    Q_INVOKABLE QString getElementText(QString elementName);
    Q_INVOKABLE QStringList getElementChildrenText(QString elementName, QString childName);
    Q_INVOKABLE void writeMusicToConfigFile(QString filename);

    const QString FirstChildElement;
    const QString MusicListElement;
    const QString MusicListElementKey;
    const QString MusicElement;
    const QString SettingElement;
    const QString ThemeElement;
    const QString VolumnElement;
    const QString PlayModeElement;

private:
    // 获得 dom
    QDomDocument getDomFromXml();

    // 保存 dom
    void savaDom(QDomDocument dom);

    // 重排 id
    void resetId(QDomDocument &dom);

    // get user data path
    QString getUserAppDataPath();

    QString xmlPath;
};

#endif // XMLPROCESS_H
