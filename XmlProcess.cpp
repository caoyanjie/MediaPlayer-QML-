#include "xmlprocess.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QXmlStreamWriter>
#include <QDomDocument>
#include <QDomElement>
#include <QDomText>
#include <QXmlStreamReader>
#include <QString>
#include <QMessageBox>
#include <QProcess>
#include <QDir>
#include <QFileInfo>
#include <QDebug>

XmlProcess::XmlProcess() :
    FirstChildElement("UserData"),
    MusicListElement("MusicList"),
    MusicListElementKey("name"),
    MusicElement("music"),
    SettingElement("Setting"),
    ThemeElement("Theme"),
    VolumnElement("Volumn"),
    PlayModeElement("PlayMode")
{
    QString userDataPath = getUserAppDataPath();
    QString appDir = userDataPath + "/MediaPlayer";
    QDir dir(appDir);
    if (!dir.exists())
    {
        dir.mkdir(appDir);
    }
    xmlPath = appDir + "/user_data.cfg";

    if (!QFileInfo(xmlPath).exists())
    {
        initXmlFile();
        addElement(FirstChildElement, MusicListElement, MusicListElementKey, "默认列表");
    }
}

// 初始化 XML 文件
void XmlProcess::initXmlFile()
{
    QFile file(xmlPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QMessageBox::warning(0, "配置文件错误", "XML 文件创建失败，用户信息无法保存！", QMessageBox::Ok);
        return;
    }

    QXmlStreamWriter stream(&file);
    stream.setAutoFormatting(true);
    stream.writeStartDocument();                // <?xml version="1.0" encoding="UTF-8"?>
    stream.writeStartElement("UserData");       // <UserData>
    stream.writeEmptyElement("Setting");
    stream.writeEndElement();
    stream.writeEndDocument();
    file.close();
}

bool XmlProcess::isElementExist(QString elementName)
{
    Q_ASSERT_X(!elementName.isEmpty(), "isElementExist", "elementName is empty!");

    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // return result
    return dom.elementsByTagName(elementName).length()>0 ? true : false;
}

// 增加元素
void XmlProcess::addElement(QString parentName, QString elementName, QString attributeKey/*=""*/, QString attributeValue/*=""*/, QString elementText/*=""*/)
{
    Q_ASSERT_X((!attributeKey.isEmpty()) || attributeValue.isEmpty(), "addElement", "key is empty and value is not empty!"); /* !(attributeKey.isEmpty() && (!attributeValue.isEmpty()) */

    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // new element
    QDomElement parentElement = dom.elementsByTagName(parentName).at(0).toElement();
    QDomElement newElement = dom.createElement(elementName);

    // set attribute
    if (!attributeKey.isEmpty())
    {
        newElement.setAttribute(attributeKey, attributeValue);
    }

    // set text
    if (!elementText.isEmpty())
    {
        QDomText newElementText = dom.createTextNode(elementText);
        newElement.appendChild(newElementText);
    }

    parentElement.appendChild(newElement);

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

// 增加元素
void XmlProcess::addElement(QString parentName, QString elementName, QList<QMap<QString, QString> > attribute, QString elementText/* ="" */)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // new element
    QDomElement parentElement = dom.elementsByTagName(parentName).at(0).toElement();
    QDomElement newElement = dom.createElement(elementName);
    for (int i=0; i<attribute.length(); ++i)
    {
        Q_ASSERT_X(attribute.at(i).firstKey().isEmpty() && (!attribute.at(i).first().isEmpty()), "addElement", "key is empty and value is not empty!");
        newElement.setAttribute(attribute.at(i).firstKey(), attribute.at(i).first());
    }
    if (!elementText.isEmpty())
    {
        QDomText newElementText = dom.createTextNode(elementText);
        newElement.appendChild(newElementText);
    }
    parentElement.appendChild(newElement);

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

void XmlProcess::addElementWithText(QString parentName, QString elementName, QString text)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // new element
    QDomElement parentElement = dom.elementsByTagName(parentName).at(0).toElement();
    QDomElement newElement = dom.createElement(elementName);
    QDomText nodeText = dom.createTextNode(text);

    // add children
    newElement.appendChild(nodeText);
    parentElement.appendChild(newElement);

    // save dom
    savaDom(dom);
}

// 增加多个元素
void XmlProcess::addElements(QString parentName, QList<QMap<QString, QMap<QString, QString> > > children)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // add children
    QDomElement parent = dom.elementsByTagName(parentName).at(0).toElement();
    for (int i=0; i<children.length(); ++i)
    {
        QString childName = children.at(i).firstKey();
        QString attributeKey = children.at(i).first().firstKey();
        QString attributeValue = children.at(i).first().first();

        QDomElement newElement = dom.createElement(childName);
        newElement.setAttribute(attributeKey, attributeValue);
        parent.appendChild(newElement);
    }

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

// 增加递归节点
void XmlProcess::addRecursiveElement(QString parentNode, QString nodeName, QList<QMap<QString, QString> > selfAttributes, QList<QMap<QString, QString> > children)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // new element
    QDomElement parentElement = dom.elementsByTagName(parentNode).at(0).toElement();
    QDomElement newElement = dom.createElement(nodeName);
    for (int i=0; i<selfAttributes.length(); ++i)
    {
        newElement.setAttribute(selfAttributes.at(i).firstKey(), selfAttributes.at(i).first());
    }

    // add children
    for (int i=0; i<children.length(); ++i)
    {
        QDomElement child = dom.createElement(children.at(i).firstKey());
        QDomText text = dom.createTextNode(children.at(i).first());
        child.appendChild(text);
        newElement.appendChild(child);
    }

    // add new element
    parentElement.appendChild(newElement);

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

// 增加递归节点
void XmlProcess::addRecursiveElement(QString parentName, QString parentAttributeKey, QString parentAttributeValue, QList<QMap<QString, QMap<QString, QString> > > selfNameAttributeKeyAndValue, QStringList childrenName, QList<QMap<QString, QString> > children)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // find parent element
    QDomElement parentElement;
    QDomNodeList nodeList = dom.elementsByTagName(parentName);
    for (int i=0; i<nodeList.length(); ++i)
    {
        if (nodeList.at(i).attributes().contains(parentAttributeKey))
        {
            QDomElement element = nodeList.at(i).toElement();
            if (element.attribute(parentAttributeKey) == parentAttributeValue)
            {
                parentElement = element;
                break;
            }
        }
    }
    Q_ASSERT_X(!parentElement.isNull(), "addRecursiveElement", "parent element is not exist!");

    // add element
    for (int i=0; i<selfNameAttributeKeyAndValue.length(); ++i)
    {
        // new element
        QString selfName = selfNameAttributeKeyAndValue.at(i).firstKey();
        QString selfAttributeKey = selfNameAttributeKeyAndValue.at(i).first().firstKey();
        QString selfAttributeValue = selfNameAttributeKeyAndValue.at(i).first().first();
        QDomElement newElement = dom.createElement(selfName);
        newElement.setAttribute(selfAttributeKey, selfAttributeValue);

        // first child
        QDomElement firstChild = dom.createElement(childrenName.at(0));
        QDomText firstText = dom.createTextNode(children.at(i).firstKey());
        firstChild.appendChild(firstText);

        // second child
        QDomElement secondChild = dom.createElement(childrenName.at(1));
        QDomText secondText = dom.createTextNode(children.at(i).first());
        secondChild.appendChild(secondText);

        // add children
        newElement.appendChild(firstChild);
        newElement.appendChild(secondChild);
        parentElement.appendChild(newElement);
    }

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

void XmlProcess::addRecursiveElement(QString parentName, QList<QMap<QString, QMap<QString, QString> > > selfNameAttributeKeyAndValue, QStringList childrenNames, QList<QList<QString> > childrenText)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // find parent element
    QDomNodeList nodeList = dom.elementsByTagName(parentName);
    Q_ASSERT_X(nodeList.length() == 1, "addRecursiveElement", "parent element is not unique or not exist!");

    QDomElement parentElement = nodeList.at(0).toElement();

    // add element
    for (int i=0; i<selfNameAttributeKeyAndValue.length(); ++i)
    {
        // new element
        QString selfName = selfNameAttributeKeyAndValue.at(i).firstKey();
        QString selfAttributeKey = selfNameAttributeKeyAndValue.at(i).first().firstKey();
        QString selfAttributeValue = selfNameAttributeKeyAndValue.at(i).first().first();
        QDomElement newElement = dom.createElement(selfName);
        newElement.setAttribute(selfAttributeKey, selfAttributeValue);

        // add children
        for (int j=0; j<childrenNames.length(); ++j)
        {
            QDomElement child = dom.createElement(childrenNames.at(j));
            QDomText textNode = dom.createTextNode(childrenText.at(i).at(j));
            child.appendChild(textNode);

            newElement.appendChild(child);
        }

        parentElement.appendChild(newElement);
    }

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

// 删除节点
void XmlProcess::removeElements(QString elementName)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    if (dom.elementsByTagName(elementName).length() == 0)
    {
        return;
    }

    // remobe elements
    while (dom.elementsByTagName(elementName).length())
    {
        QDomNode parent = dom.elementsByTagName(elementName).at(0).parentNode();
        parent.removeChild(dom.elementsByTagName(elementName).at(0));
    }

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

void XmlProcess::removeElementByAttribute(QString elementName, QMap<QString, QString> attributeAndValue)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // find nodes
    QDomNodeList targetList = dom.elementsByTagName(elementName);
    QDomNode target;
    for (int i=0; i<targetList.length(); ++i)
    {
        QDomElement element = targetList.at(i).toElement();
        if (element.attributes().contains(attributeAndValue.firstKey()))
        {
            if (element.attribute(attributeAndValue.firstKey()) == attributeAndValue.first())
            {
                target = targetList.at(i);
            }
        }
    }

    // remove node
    Q_ASSERT_X(!target.isNull(), "removeXmlElementByAttribute", "element name is not exist!");
    QDomNode parent = target.parentNode();
    parent.removeChild(target);

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

// 删除指定元素的所有子元素
void XmlProcess::removeAllChildrenByAttribute(QString elementName, QString attributeKey, QString attributeValue)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // find node
    QDomNodeList targetList = dom.elementsByTagName(elementName);
    QDomNode target;
    for (int i=0; i<targetList.length(); ++i)
    {
        QDomElement element = targetList.at(i).toElement();
        if (element.attributes().contains(attributeKey))
        {
            if (element.attribute(attributeKey) == attributeValue)
            {
                target = targetList.at(i);
            }
        }
    }

    // remove all children
    Q_ASSERT_X(!target.isNull(), "removeAllChildrenByAttribute", "element name is not exist!");
    while (target.hasChildNodes())
    {
        target.removeChild(target.childNodes().at(0));
    }

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

// 修改元素文本
void XmlProcess::alterElementText(QString parentName, QString selfName, QString text)
{
    Q_ASSERT_X(!parentName.isEmpty() && !selfName.isEmpty() && !text.isEmpty(), "alterElementText", "arguments is empty!");

    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // find nodes
    QDomNodeList parentList = dom.elementsByTagName(parentName);
    Q_ASSERT_X(parentList.length() == 1, "alterElementText", "parentName is not exist or not unique!");

    QDomNodeList elementList = parentList.at(0).toElement().elementsByTagName(selfName);
    Q_ASSERT_X(elementList.length() == 1, "alterElementText", "elementName is not exist or not unique!");

    QDomNodeList chileren = elementList.at(0).childNodes();
    Q_ASSERT_X(chileren.length() == 1, "alterElementText", "source data is not exist, can't alter!");

    QDomText textNode = chileren.at(0).childNodes().at(0).toText();

    // alter node
    textNode.setData(text);

    // save dom
    savaDom(dom);
}

// 修改元素属性值
void XmlProcess::alterElementAttribute(QString elementName, QMap<QString, QString> attribute)
{
    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // alter node


    // save dom
    savaDom(dom);
}

// 修改具有某属性的元素的文本
void XmlProcess::alterElementTextByAttribute(QString parentName, QMap<QString, QString> parentAttribute, QString elementName, QString text)
{
    Q_ASSERT_X(!parentName.isEmpty() && !parentAttribute.isEmpty() && !text.isEmpty(), "alterElementTextByAttribute", "arguments is empty!");

    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // find parent
    QDomNodeList parenttList = dom.elementsByTagName(parentName);
    QDomElement parent;
    for (int i=0; i<parenttList.length(); ++i)
    {
        if (parenttList.at(i).attributes().contains(parentAttribute.firstKey()))
        {
            if (parenttList.at(i).toElement().attribute(parentAttribute.firstKey()) == parentAttribute.first())
            {
                parent = parenttList.at(i).toElement();
            }
        }
    }
    Q_ASSERT_X(!parent.isNull(), "alterElementTextByAttribute", "elementName is not exist or not unique!");

    QDomNodeList elementList = parent.elementsByTagName(elementName);
    Q_ASSERT_X(elementList.length() == 1, "alterElementText", "source data is not exist, can't alter!");

    QDomText textNode = elementList.at(0).childNodes().at(0).toText();qDebug() << textNode.data();

    // alter node
    textNode.setData(text);

    // save dom
    savaDom(dom);
}

// 获得数据
QList<QMap<QString, QList<QMap<QString, QString> > > > XmlProcess::getElementAttributeValueAndChildrenText(QString elementName, QStringList elementNames)
{
    QList<QMap<QString, QList<QMap<QString, QString> > > > result;

    QFile file(xmlPath);
    if (!file.open(QIODevice::ReadOnly))
    {
        QMessageBox::warning(0, "配置文件错误", "XML 文件打开失败，无法获取用户数据！", QMessageBox::Ok);
        return result;
    }

    QList<QMap<QString, QString> > brotherElementsTextList;

    QString attributeValue;
    QString firstValue;
    QString secondValue;

    QXmlStreamReader reader;
    reader.setDevice(&file);

    while (!reader.atEnd())
    {
        QXmlStreamReader::TokenType type = reader.readNext();

        switch(type)
        {
        case QXmlStreamReader::StartElement:
            if (reader.name() == elementName)
            {
                attributeValue = reader.attributes().at(0).value().toString();
            }
            else if (reader.name() == elementNames.at(0))
            {
                firstValue = reader.readElementText();
            }
            else if (reader.name() == elementNames.at(1))
            {
                secondValue = reader.readElementText();

                QMap<QString, QString> brotherElementsText;
                brotherElementsText.insert(firstValue, secondValue);
                brotherElementsTextList.append(brotherElementsText);
            }
            break;
        case QXmlStreamReader::EndElement:
            if (!attributeValue.isNull() && reader.name()==elementName)
            {
                QMap<QString, QList<QMap<QString, QString> > > values;
                values.insert(attributeValue, brotherElementsTextList);
                result.append(values);
                brotherElementsTextList.clear();
            }
            break;
        default:
            break;
        }
    }

    file.close();
    return result;
}

QList<QMap<QString, QString> > XmlProcess::getChildrenText(QString elementName, QStringList childrenNames)
{
    QList<QMap<QString, QString> > result;

    QFile file(xmlPath);
    if (!file.open(QIODevice::ReadOnly))
    {
        QMessageBox::warning(0, "配置文件错误", "XML 文件打开失败，无法获取用户数据！", QMessageBox::Ok);
        return result;
    }

    QString currentElement;
    QString firstValue;
    QString secondValue;

    QXmlStreamReader reader;
    reader.setDevice(&file);

    while (!reader.atEnd())
    {
        QXmlStreamReader::TokenType type = reader.readNext();

        switch(type)
        {
        case QXmlStreamReader::StartElement:
            if (reader.name() == elementName)
            {
                currentElement = elementName;
            }
            else if (reader.name() == childrenNames.at(0) && !currentElement.isNull())
            {
                firstValue = reader.readElementText();
            }
            else if (reader.name() == childrenNames.at(1) && !currentElement.isNull())
            {
                secondValue = reader.readElementText();

                QMap<QString, QString> brotherElementsText;
                brotherElementsText.insert(firstValue, secondValue);
                result.append(brotherElementsText);
            }
            break;
        case QXmlStreamReader::EndElement:
            if (!currentElement.isNull() && reader.name()==elementName)
            {
                file.close();
                return result;
            }
            break;
        default:
            break;
        }
    }

    file.close();
    return result;
}

/*
QList<QStringList> XmlProcess::getChildrenText(QString elementName, QStringList childrenNames)
{
    QList<QStringList> result;

    QFile file(xmlPath);
    if (!file.open(QIODevice::ReadOnly))
    {
        QMessageBox::warning(0, "配置文件错误", "XML 文件打开失败，无法获取用户数据！", QMessageBox::Ok);
        return result;
    }

    QString currentElement;
    QStringList children;

    QXmlStreamReader reader;
    reader.setDevice(&file);

    while (!reader.atEnd())
    {
        QXmlStreamReader::TokenType type = reader.readNext();

        switch(type)
        {
        case QXmlStreamReader::StartElement:
            if (reader.name() == elementName)
            {
                currentElement = elementName;
            }
            else if (!currentElement.isNull())
            {
                for (int i=0; i<childrenNames.length(); ++i)
                {
                    if (reader.name() == childrenNames.at(i))
                    {
                        children.append(reader.readElementText());
                        if (children.length() == childrenNames.length())
                        {
                            result.append(children);
                            children.clear();
                        }
                        break;
                    }
                }
            }
            break;
        case QXmlStreamReader::EndElement:
            if (!currentElement.isNull() && reader.name()==elementName)
            {
                file.close();
                return result;
            }
            break;
        default:
            break;
        }
    }

    file.close();
    return result;
}
*/

// get element text
QString XmlProcess::getElementText(QString elementName)
{
    Q_ASSERT_X(!elementName.isEmpty(), "getElementText", "argument is empty!");

    // get dom
    QDomDocument dom;
    dom = getDomFromXml();

    // find element
    Q_ASSERT_X(dom.elementsByTagName(elementName).length() == 1, "getElementText", "element is not exist or not unique!");
    return dom.elementsByTagName(elementName).at(0).toElement().text();
}

QStringList XmlProcess::getElementChildrenText(QString elementName, QString childName)
{
    QStringList result;

    QFile file(xmlPath);
    if (!file.open(QIODevice::ReadOnly))
    {
        QMessageBox::warning(0, "配置文件错误", "XML 文件打开失败，无法获取用户数据！", QMessageBox::Ok);
        return result;
    }

    QString currentElement;
    QXmlStreamReader reader;
    reader.setDevice(&file);
    while (!reader.atEnd())
    {
        QXmlStreamReader::TokenType type = reader.readNext();

        switch(type)
        {
        case QXmlStreamReader::StartElement:
            if (reader.name() == elementName)
            {
                currentElement = elementName;
            }
            else if (reader.name() == childName && !currentElement.isNull())
            {
                result.append(reader.readElementText());
            }
            break;
        case QXmlStreamReader::EndElement:
            if (!currentElement.isNull() && reader.name()==elementName)
            {
                file.close();
                return result;
            }
            break;
        default:
            break;
        }
    }

    file.close();
    return result;
}

void XmlProcess::writeMusicToConfigFile(QString filename)
{
    QDomDocument dom;
    dom = getDomFromXml();

    // find parent element
    QDomElement parentElement;
    QDomNodeList nodeList = dom.elementsByTagName(MusicListElement);
    for (int i=0; i<nodeList.length(); ++i)
    {
        if (nodeList.at(i).attributes().contains(MusicListElementKey))
        {
            QDomElement element = nodeList.at(i).toElement();
            if (element.attribute(MusicListElementKey) == "默认列表")
            {
                parentElement = element;
                break;
            }
        }
    }

    // add element
        // new element
        QString selfName = MusicElement;
        QString selfAttributeKey = "id";
        QString selfAttributeValue = "1";
        QDomElement newElement = dom.createElement(selfName);
        newElement.setAttribute(selfAttributeKey, selfAttributeValue);

        // first child
        QDomElement firstChild = dom.createElement("url");
        QDomText firstText = dom.createTextNode(filename);
        firstChild.appendChild(firstText);

        // second child
        QDomElement secondChild = dom.createElement("name");
        QDomText secondText = dom.createTextNode(filename);
        secondChild.appendChild(secondText);

        // add children
        newElement.appendChild(firstChild);
        newElement.appendChild(secondChild);
        parentElement.appendChild(newElement);

    // reset id
    resetId(dom);

    // save dom
    savaDom(dom);
}

// 获取 dom
QDomDocument XmlProcess::getDomFromXml()
{
    QDomDocument dom;

    // open file
    QFile fileReader(xmlPath);
    if (!fileReader.open(QIODevice::ReadOnly))
    {
        QMessageBox::warning(0, "配置文件错误", "XML 文件读取失败，用户信息无法保存！", QMessageBox::Ok);
        return dom;
    }

    // read dom
    dom.setContent(&fileReader);
    fileReader.close();

    //return dom
    return dom;
}

// 保存 dom
void XmlProcess::savaDom(QDomDocument dom)
{
    QFile fileWriter(xmlPath);
    if (!fileWriter.open(QIODevice::WriteOnly))
    {
        QMessageBox::warning(0, "配置文件错误", "XML 文件保存失败，用户信息无法保存！", QMessageBox::Ok);
        return;
    }
    QTextStream stream(&fileWriter);
    dom.save(stream, 4);
    fileWriter.close();
}

// 重排 id 值
void XmlProcess::resetId(QDomDocument &dom)
{
    QDomNodeList two = dom.childNodes();
    QList<QDomNode> root;
    for (int i=0; i<two.length(); ++i)
    {
        root.append(two.at(i));
    }

    while (root.length() > 0)
    {
        QDomNode parent = root.at(0);
        root.pop_front();
        QDomNodeList children = parent.childNodes();
        QString base = parent.toElement().attribute(this->MusicListElementKey);
        int num = 0;
        for (int i=0; i<children.length(); ++i)
        {
            if (children.at(i).attributes().contains("id"))
            {
                QDomElement element = children.at(i).toElement();
                element.setAttribute("id", QObject::tr("%1-%2").arg(base).arg(num));
                num ++;
            }
            if (children.at(i).hasChildNodes())
            {
                root.append(children.at(i));
            }
        }
    }
}

QString XmlProcess::getUserAppDataPath()
{
    QStringList environmentList = QProcess::systemEnvironment();
       QString appPath("");
       foreach (QString environment, environmentList )
       {
           if (environment.startsWith("APPDATA=", Qt::CaseInsensitive))
           {
               appPath = environment.mid(QString("APPDATA=").length());
               break;
           }
       }
       return appPath ;
}
