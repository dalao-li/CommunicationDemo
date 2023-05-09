/**
*  Hwa Create Corporation Ltd..
*  Yi.18, No8 Dongbeiwang West Road, Haidian District Beijing, 100094 P.R.China
*  (c) Copyright 2018, Hwa Create Corporation Ltd.
*  All rights reserved.                                                                        *
*  @file     BSTExcutor.h
*  @brief    Acceptor for BST event.
*  @author   Weijun Shi
*  @date     2018-5-23
*  @version  1.0
*/

#ifndef BST_BSTEXCUTOR_H_
#define BST_BSTEXCUTOR_H_

#include <QString>

class BSTEvent;
class BSTExcutor
{
public:
    virtual ~BSTExcutor() {}

    virtual void process(BSTEvent* event) = 0;
};

#endif // BST_BSTEXCUTOR_H_
