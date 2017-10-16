#ifndef SHORT_ID_LIST_H
#define SHORT_ID_LIST_H


#include <qhash.h>
#include <qstring.h>
#include <stdint.h>

class shortIdList
{
private:
	QHash<uint64_t,QString> shortIdMap;
public:
   shortIdList();
    
   

    QString getShortID(uint64_t unique_id);

};


#endif // SHORT_ID_LIST_H
