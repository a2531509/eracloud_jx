/**----------------------------------------------------*
*@author yangn                                         *
*@date 2015-06-24                                      *
*卡操作相关函数                                          *                                                                                                  |
*读卡信息:readcardinfo(),getcardinfo()                  *
*@param card_No 充值卡号                                *
*@param indata  充值输入字符串                           *
*卡充值:writecard_cardrecharge(card_No,indata)          *
*卡消费:writecard_onlydecrease(card_No,indata)          *
*读取二代身份证getcertinfo                               *
*------------------------------------------------------*/

/**
 * 根据错误码,获取对应错误信息
 * @param
 */
function cardgeterrmessage(status){
    try{
        CardCtl.CardGetErrMessage(status);
        if(CardCtl.Status == 0){
            return CardCtl.Outdata;
        }else{
            return "错误码未定义或动态库未正确加载:" + status;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        //closecardctlport();
        return errMsg;
    }
}
/**
 * 打开读卡端口
 */
function opencardctlport(){
    try {
        CardCtl.CardOpenSession();
        if(CardCtl.Status >= 0) {
            return true;
        }else{
            $.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'warning');
            return false;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'warning');
        return false;
    }finally{
        //closecardctlport();
    }
}
/**
 * 关闭读卡端口
 */
function closecardctlport(){
    try{
        CardCtl.CardCloseSession();
    }catch(e){

    }
}
/**
 * 读卡片信息
 */
function getcardinfo(notopen){
    var cardinfoarray = new Array(32);
    cardinfoarray["errMsg"] = "";
    cardinfoarray["status"] = "1";
    var isOpenOk = false;
    try {
        if (!notopen) {
            isOpenOk = opencardctlport();
        }
        if(!isOpenOk){
            return cardinfoarray;
        }
        CardCtl.CardReadCardInfo(1001);// 非接触式卡片信息，返回3F00信息
        if(CardCtl.Status == 0){
            cardinfoarray['fkfbs'] = CardCtl.Outdata.subCHString(0,8).trim();//发卡方标识
            cardinfoarray['flow_No'] = CardCtl.Outdata.subCHString(8,28).trim();//发卡流水,卡号
            cardinfoarray['use_Flag'] = CardCtl.Outdata.subCHString(28,30).trim();//启用标志,卡片是否启用
            cardinfoarray["struct_Main_Type"] = CardCtl.Outdata.subCHString(30, 32).trim();// 卡主类型
            cardinfoarray["struct_Child_Type"] = CardCtl.Outdata.subCHString(32, 34).trim();// 卡子类型
            cardinfoarray["card_Valid_Date"] = CardCtl.Outdata.subCHString(34,42).trim();// 卡有效日期YYYYMMDD
            var busType = CardCtl.Outdata.subCHString(30,32).trim();
            if(busType == '01'){
               cardinfoarray["busTypeName"] = "普通卡";
            }else if(busType == '10'){
               cardinfoarray["busTypeName"] = "学生卡";
            }else if(busType == '11'){
               cardinfoarray["busTypeName"] = "敬老卡";
            }else if(busType == '20'){
               cardinfoarray["busTypeName"] = "免费老年卡";
            }else if(busType == '21'){
               cardinfoarray["busTypeName"] = "爱心卡";
            }else{
               cardinfoarray["busTypeName"] = "普通卡";
            }
            //公共钱包应用信息
            CardCtl.CardReadCardInfo(1002);
            if(CardCtl.status == 0){
                cardinfoarray["fkfbs2"] = CardCtl.Outdata.subCHString(0,8).trim();//行业代码
                cardinfoarray["indus_Code"] = CardCtl.Outdata.subCHString(8,12).trim();//行业代码
                cardinfoarray["hlht_Flag"] = CardCtl.Outdata.subCHString(12,16).trim();//互联互通标识
                cardinfoarray["bus_Use_Flag"] = CardCtl.Outdata.subCHString(16,18).trim();//应用启用标示
                cardinfoarray["use_Version"] = CardCtl.Outdata.subCHString(18,20).trim();//应用版本号
                cardinfoarray['card_No'] = CardCtl.Outdata.subCHString(20,40).trim();//发卡流水,卡号
                cardinfoarray["start_Date"] = CardCtl.Outdata.subCHString(40,48).trim();//应用启用日期
                cardinfoarray["valid_Date"] = CardCtl.Outdata.subCHString(48,56).trim();//应用有效期
                cardinfoarray["wallet_Amt"] = CardCtl.Outdata.subCHString(62,72).trim();//钱包余额
                cardinfoarray["name"] = CardCtl.Outdata.subCHString(74,94).trim();//姓名
                cardinfoarray["cert_No"] = CardCtl.Outdata.subCHString(94,126).trim();//证件号码
                cardinfoarray["cert_Type"] = CardCtl.Outdata.subCHString(126,128).trim();//证件类型  需要转码
                cardinfoarray["sex"] = CardCtl.Outdata.subCHString(128,129).trim();//性别
                cardinfoarray["sub_Card_No"] = CardCtl.Outdata.subCHString(129,138).trim();//接触卡号
                cardinfoarray["consume_Tr_Count"] = CardCtl.Outdata.subCHString(138,144).trim();//消费计数器
                cardinfoarray["recharge_Tr_Count"] = CardCtl.Outdata.subCHString(150,156).trim();//充值计数器
                cardinfoarray["status"] = "0";
            }else{
                if(CardCtl.Status == "-227265"){
                    cardinfoarray["errMsg"] = "<psan style=\"color:red;font-weight:600;font-style:italic;\">卡片应用已锁定，无法进行读取！</span>";
                }else{
                    cardinfoarray["errMsg"] = cardgeterrmessage(CardCtl.Status);
                }
            }
            CardCtl.CardReadCardInfo(3001);
            if(CardCtl.status == 0){
                cardinfoarray["status_zxc"] = "0";//读取租车内容是否成功标志 0 成功  1 失败
                cardinfoarray["rentalType"] = CardCtl.Outdata.subCHString(20,22).trim();//交易类型
                cardinfoarray["rentalTime"] = CardCtl.Outdata.subCHString(22,36).trim();//租车时间
                cardinfoarray["rentalCarNo"] = CardCtl.Outdata.subCHString(36,44).trim();//车号
                cardinfoarray["rentalValidTime"] = CardCtl.Outdata.subCHString(44,47).trim();//有效期
                cardinfoarray["rentalReturnTime"] = CardCtl.Outdata.subCHString(47,61).trim();//还车时间
                cardinfoarray["rentalFee"] = CardCtl.Outdata.subCHString(61,71).trim();//租车费用
                cardinfoarray["rentalRegion"] = CardCtl.Outdata.subCHString(71,73).trim();//开通租车区域
                cardinfoarray["rentalFeeFlag"] = CardCtl.Outdata.subCHString(73,75).trim();//押金标志
                cardinfoarray["rentalResv"] = CardCtl.Outdata.subCHString(75,79).trim();//预留
            }else{
                cardinfoarray["status_zxc"] = "1";
                cardinfoarray["errMsg"] = cardgeterrmessage(CardCtl.Status);
            }
        }else{
            cardinfoarray["errMsg"] = cardgeterrmessage(CardCtl.Status);
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        cardinfoarray["errMsg"] = errMsg;
    }finally {
        closecardctlport();// 关闭端口
    }
    return cardinfoarray;
}
/**
 * 单芯片卡信息写入个人信息
 * cardNo 卡号 长度20
 * name 持卡人姓名 20 左对齐，不足位右补空格
 * certNo  持卡人证件号码  32 左对齐，不足位右补空格
 * certType 持卡人证件类型 2 身份证 00 军官证 01 护照 02 入境证（仅限香港/台湾居民使用）03 临时身份证	04 其他 05
 * sex 性别  1 持卡人性别
 * subCardNo 9 接触式卡号
 * @returns {boolean}
 */
function modifypersonalinfo(cardNo,name,certNo,certType,sex){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardModifyCardInfo(4001,cardNo + name +certNo + certType + sex + "         ");
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',"写卡出现错误，" + cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closecardctlport();// 关闭端口
    }
}
/**
 * 嘉兴市民卡自行车应用开通与关闭
 * @param cardNo 卡号 4位城市代码+16位应用序列号
 * @param dealType 交易类型
 *        00  未开通租车功能
 *        01  已租车
 *        02  开通租车功能
 *        04  已还车
 *        08  欠费还车
 * @param regionCode 开通区域
 *        03海盐市 09嘉兴市通用
 *        09嘉兴市
 * @param flag 押金标志
 *        00 押金200元
 *		  01 押金 100元
 *		  02押金  0元
 *	      03 押金 300元
 *	      FF  业务注销 （无押金）
 */
function writecard_openorclosezxc(cardNo,dealType,regionCode,flag){
    var ret =  new Object();
    ret["status"] = "0";
    ret["errMsg"] = "";
    try{
        if(typeof(cardNo) != "string" || dealNull(cardNo).length != 20){
            throw new Error("写卡卡号不正确！");
        }
        if(dealType != "00" && dealType != "01" && dealType != "02" && dealType != "04" && dealType != "08"){
            throw new Error("写卡交易类型不正确！");
        }
        if(typeof(regionCode) != "string" && dealNull(regionCode) != "09"){
            throw new Error("区域不正确！");
        }
        if(typeof(flag) != "string" || dealNull(flag) != "00"){
            throw new Error("押金标志不正确！");
        }
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            ret["status"] = "1";
            ret["errMsg"] = "打开端口错误！";
        }
        CardCtl.CardModifyCardInfo(8001,cardNo + dealType + regionCode + flag);
        if(CardCtl.Status != 0){
            ret["status"] = "1";
            ret["errMsg"] = cardgeterrmessage(CardCtl.Status);
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        ret["status"] = "1";
        ret["errMsg"] = errMsg;
    }finally{
        closecardctlport();
    }
    return ret;
}

function writecard_openorclosezxc2(cardNo,writecarddata,writecarddata2){
    var ret =  new Object();
    ret["status"] = "0";
    ret["errMsg"] = "";
    try{
        if(typeof(cardNo) != "string" || dealNull(cardNo).length != 20){
            throw new Error("写卡卡号不正确！");
        }
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            ret["status"] = "1";
            ret["errMsg"] = "打开端口错误！";
        }
        CardCtl.CardModifyCardInfo(8001,cardNo + writecarddata);
        CardCtl.CardLoad(1001,cardNo + writecarddata2);
        if(CardCtl.Status != 0){
            ret["status"] = "1";
            ret["errMsg"] = cardgeterrmessage(CardCtl.Status);
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        ret["status"] = "1";
        ret["errMsg"] = errMsg;
    }finally{
        closecardctlport();
    }
    return ret;
}

/**
 * 卡片充值
 * @param cardNo     充值卡号
 * @param indata     传入字符串
 * @returns {Boolean}充值是否成功
 */
function wirtecard_recharge(cardNo,indata){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardLoad(1001,cardNo + indata);
        if (CardCtl.Status == 0){
            return true;
        }else {
            $.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally{
        closecardctlport();// 关闭端口
    }
}
/**
 * 卡片消费
 * @param cardNo     充值卡号
 * @param indata     传入字符串
 * @returns {Boolean}消费是否成功
 */
function wirtecard_consume(cardNo,indata){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardConsume(1001,cardNo + indata);
        if (CardCtl.Status == 0){
            return true;
        }else {
            //$.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally{
        closecardctlport();// 关闭端口
    }
}

/**
 * 卡片复合消费（自行车开通）
 * @param cardNo     卡号
 * @param indata     传入字符串
 * @returns {Boolean}消费是否成功
 */
function wirtecard_consume_zxc(cardNo,indata){
    var ret =  new Object();
    ret["status"] = "0";
    ret["errMsg"] = "";
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            ret["status"] = "1";
            ret["errMsg"] = "打开端口错误！";
        }
        CardCtl.CardConsume(2001,cardNo + indata);
        if(CardCtl.Status != 0){
            ret["status"] = "1";
            ret["errMsg"] = cardgeterrmessage(CardCtl.Status);
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        ret["status"] = "1";
        ret["errMsg"] = errMsg;
    }finally{
        closecardctlport();
    }
    return ret;
}
/**
 * 获取密码键盘的明文密码
 */
function getPlaintextPwd(){
    try{
        CardCtl.CardGetPin(1);//语音提示类型码（1表示请输入密码，2表示请再次输入密码）
        if(CardCtl.Status == 0){
            return CardCtl.Outdata;
        }else{
            $.messager.alert('系统消息','获取密码信息失败，请重新进行输入！','error');
            return '';
        }
    }catch(e){
        defaultCatchErrMsg(e);
        return '';
    }
}
/**
 * 获取密码键盘确认密码的明文密码
 */
function getPlaintextEnsurePwd(){
    try{
        CardCtl.CardGetPin(2);//语音提示类型码（1表示请输入密码，2表示请再次输入密码）
        if(CardCtl.Status == 0){
            return CardCtl.Outdata;
        }else{
            $.messager.alert('系统消息','获取密码信息失败，请重新进行输入！','error');
            return '';
        }
    }catch(e){
        defaultCatchErrMsg(e);
        return '';
    }
}
/**
 * 获取密码键盘密文时，卡号不足13时把卡号转成
 */
function cardno2ascii(av_card_no) {
    var ret = "";
    if (av_card_no.length < 13) {
        for (var i = 0; i < av_card_no.length; i++) {
            ret = ret + av_card_no.substring(i, i + 1).charCodeAt().toString(16);
        }
    } else {
        ret = av_card_no;
    }
    return ret;
}

/**
 * 获取密码键盘密文
 */
function getEnPin(type,av_card_no){
    var temp_cardno = cardno2ascii(av_card_no);
    temp_cardno = temp_cardno.substring(temp_cardno.length - 13,temp_cardno.length - 1);
    CardCtl.CardGetEnPin(type,0,0,temp_cardno);
    if (CardCtl.Status < 0) {
        $.messager.alert("系统消息","获取密码信息失败，请重新进行输入！" + cardgeterrmessage(CardCtl.Status),"error");
        return "";
    }else{
        return CardCtl.Outdata;
    }
}

/**
 * 卡片应用锁定
 */
function CardAppBlock1001(){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardAppBlock(1001);
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closecardctlport();// 关闭端口
    }
}
/**
 * 卡片应用解锁
 */
function CardAppunBlock1001(){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardAppUnBlock(1001);
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closecardctlport();// 关闭端口
    }
}
/**
 * 读取卡内充值信息
 */
function getcardrechargeinfo(){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return -1;
        }
        CardCtl.CardReadLoadInfo(1001);
        if(CardCtl.Status >= 0){
            return CardCtl.Outdata;
        }else{
            //$.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return -1;
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return -1;
    }finally {
        closecardctlport();// 关闭端口
    }
}
/**
 * 读取卡内消费明细
 */
function getcardconsumeinfo(){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return -1;
        }
        CardCtl.CardReadPurchaseLocalInfo(1001);
        if(CardCtl.Status >= 0){
            return CardCtl.Outdata;
        }else{
            //$.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return -1;
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return -1;
    }finally {
        closecardctlport();// 关闭端口
    }
}
/**
 * 读取二代身份证信息
 */
function getcertinfo(){
    var o = new Array(20);
    try{
        CardCtl.CardGetPIDInfo("c:");
        if(CardCtl.Status == 0){
            o["name"] = CardCtl.Name;
            if(CardCtl.Sex == "男"){
                o["sex"] = "1";
            }else if(CardCtl.Sex == "女"){
                o["sex"] = "2";
            }
            o["sexName"] = CardCtl.Sex;
            o["nation"] = CardCtl.Nation;
            o["birth"] = CardCtl.Birth;
            o["address"] = CardCtl.Address;
            o["cert_No"] = CardCtl.Number;
            o["department"] = CardCtl.Department;
            o["valid_Date"] = CardCtl.Validdate;
            o["photo"] = CardCtl.PictureBuffer;
            return o;
        }else{
            $.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return o;
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return o;
    }
}
/**
 * 卡信息修改 公交类型  有效期
 * @param cardNo    卡号
 * @param busType   公交类型
 * @param cardValidDate  卡有效期
 * @returns {Boolean}
 */
function CardModifyCardInfo(cardNo,busType,cardValidDate){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardModifyCardInfo(5001,cardNo + busType);
        CardCtl.CardModifyCardInfo(2001,cardNo + cardValidDate);
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',"写卡出现错误，" + cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closecardctlport();// 关闭端口
    }
}

/**
 * 打开接触式读卡端口
 */
function openTouchPort(){
    try {
        CardCtl.CardTouchOpenSession();
        if(CardCtl.Status >= 0) {
            return true;
        }else{
            $.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'warning');
            return false;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'warning');
        return false;
    }finally{
        //closecardctlport();
    }
}
/**
 * 关闭接触式读卡端口
 */
function closeTouchPort(){
    try{
        CardCtl.CardTouchCloseSession();
    }catch(e){

    }
}
/**
 * 读取接触式发卡信息
 * @returns {Boolean}
 */
function getTouchCardInfo_9901(notopen){
    var cardinfoarray = new Array(20);
    cardinfoarray["errMsg"] = "";
    cardinfoarray["status"] = "1";
    var isOpenOk = false;
    try{
        if (!notopen) {
            isOpenOk = openTouchPort();
        }
        if(!isOpenOk){
            return cardinfoarray;
        }
        CardCtl.CardTouchTransaction(9901, "123456");
        if(CardCtl.Status == 0){
            cardinfoarray['card_Flag'] = CardCtl.Outdata.subCHString(0,32).trim();//卡识别码
            cardinfoarray['card_Category'] = CardCtl.Outdata.subCHString(32,33).trim();//卡的类别
            cardinfoarray['card_Version'] = CardCtl.Outdata.subCHString(33,37).trim();//规范版本
            cardinfoarray["init_Org"] = CardCtl.Outdata.subCHString(37,61).trim();//初始化机构编号
            cardinfoarray["card_Start_Date"] = CardCtl.Outdata.subCHString(61,69).trim();//发卡日期
            cardinfoarray["card_Valid_Date"] = CardCtl.Outdata.subCHString(69,77).trim();//卡有效期
            cardinfoarray["sub_Card_No"] = CardCtl.Outdata.subCHString(77,86).trim();//卡号
            cardinfoarray["status"] = "0";
        }else{
            if(CardCtl.Status == "-227265"){
                cardinfoarray["errMsg"] = "<psan style=\"color:red;font-weight:600;font-style:italic;\">卡片应用已锁定，无法进行读取！</span>";
            }else{
                cardinfoarray["errMsg"] = cardgeterrmessage(CardCtl.Status);
            }
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        cardinfoarray["errMsg"] = errMsg;
    }finally {
        closeTouchPort();// 关闭端口
    }
    return cardinfoarray;
}

/**
 * 读取接触式发卡信息
 * @returns {Boolean}
 */
function getTouchCardInfo_9902(notopen){
    var cardinfoarray = new Array(8);
    cardinfoarray["errMsg"] = "";
    cardinfoarray["status"] = "1";
    var isOpenOk = false;
    try{
        if (!notopen) {
            isOpenOk = openTouchPort();
        }
        if(!isOpenOk){
            return cardinfoarray;
        }
        CardCtl.CardTouchTransaction(9902, "123456");
        if(CardCtl.Status == 0){
            cardinfoarray['cert_No'] = CardCtl.Outdata.subCHString(0,18).trim();//证件号码
            cardinfoarray['name'] = CardCtl.Outdata.subCHString(18,48).trim();//姓名
            cardinfoarray['gender'] = CardCtl.Outdata.subCHString(48,49).trim();//性别
            cardinfoarray["nation"] = CardCtl.Outdata.subCHString(49,51).trim();//民族
            cardinfoarray["birth_Place"] = CardCtl.Outdata.subCHString(51,57).trim();//出生地
            cardinfoarray["card_Valid_Date"] = CardCtl.Outdata.subCHString(57,65).trim();//出生日期
            cardinfoarray["status"] = "0";
        }else{
            if(CardCtl.Status == "-227265"){
                cardinfoarray["errMsg"] = "<psan style=\"color:red;font-weight:600;font-style:italic;\">卡片应用已锁定，无法进行读取！</span>";
            }else{
                cardinfoarray["errMsg"] = cardgeterrmessage(CardCtl.Status);
            }
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        cardinfoarray["errMsg"] = errMsg;
    }finally {
        closeTouchPort();// 关闭端口
    }
    return cardinfoarray;
}

/**
 * 读取接触式发卡信息
 * @returns {Boolean}
 */
function getTouchCardInfo_9903(notopen){
    var cardinfoarray = new Array(8);
    cardinfoarray["errMsg"] = "";
    cardinfoarray["status"] = "1";
    var isOpenOk = false;
    try{
        if (!notopen) {
            isOpenOk = openTouchPort();
        }
        if(!isOpenOk){
            return cardinfoarray;
        }
        CardCtl.CardTouchTransaction(9903,"123456");
        if(CardCtl.Status == 0){
            cardinfoarray['card_Flag'] = CardCtl.Outdata.subCHString(0,32).trim();//卡识别码
            cardinfoarray['sub_Card_No'] = CardCtl.Outdata.subCHString(32,41).trim();//卡号
            cardinfoarray['cert_No'] = CardCtl.Outdata.subCHString(41,59).trim();//证件号码
            cardinfoarray["name"] = CardCtl.Outdata.subCHString(59,89).trim();//姓名
            cardinfoarray["gender"] = CardCtl.Outdata.subCHString(89,90).trim();//性别
            cardinfoarray["nation"] = CardCtl.Outdata.subCHString(90,92).trim();//民族
            cardinfoarray["birth_Place"] = CardCtl.Outdata.subCHString(92,98).trim();//出生地
            cardinfoarray["birthday"] = CardCtl.Outdata.subCHString(98,106).trim();//出生日期
            cardinfoarray["reside_Type"] = CardCtl.Outdata.subCHString(106,107).trim();//户口类型
            cardinfoarray["letter_Addr"] = CardCtl.Outdata.subCHString(107,187).trim();//通讯地址
            cardinfoarray["post_Code"] = CardCtl.Outdata.subCHString(187,193).trim();//邮政编码
            cardinfoarray["tel_No"] = CardCtl.Outdata.subCHString(193,208).trim();//邮政编码
            cardinfoarray["corp_Name"] = CardCtl.Outdata.subCHString(208,278).trim();//单位名称
            cardinfoarray["status"] = "0";
        }else{
            if(CardCtl.Status == "-227265"){
                cardinfoarray["errMsg"] = "<psan style=\"color:red;font-weight:600;font-style:italic;\">卡片应用已锁定，无法进行读取！</span>";
            }else{
                cardinfoarray["errMsg"] = cardgeterrmessage(CardCtl.Status);
            }
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        cardinfoarray["errMsg"] = errMsg;
    }finally {
        closeTouchPort();// 关闭端口
    }
    return cardinfoarray;
}

/**
 * 修改接触式卡信息统筹区域修改
 * @returns {Boolean} true 修改成功 false 修改失败
 */
function modifyTouchRegion(cardNo,regionId){
    try {
        if(dealNull(cardNo).length != 9){
            $.messager.alert('系统消息',"写卡出现错误，卡号不正确！",'error');
            return false;
        }
        if(dealNull(regionId).length != 6){
            $.messager.alert('系统消息',"写卡出现错误，统筹区域编码不正确！",'error');
            return false;
        }
        var isOpenPortOk = openTouchPort();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardTouchTransaction(9905,cardNo + regionId);
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',"写卡出现错误，" + cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch (e) {
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closeTouchPort();// 关闭端口
    }
}
/**
 * 验证接触式密码是否正确
 * @param pwd  密码
 * @returns {Boolean}
 */
function judgeTouchPwd(pwd,nums){
    try{
        var isOpenPortOk = openTouchPort();
        if(!isOpenPortOk){
            nums = 0;
            return false;
        }
        if(dealNull(pwd).length != 6 || typeof(pwd) != "string"){
            //$.messager.alert("系统消息","输入密码长度不正确！","error");
            nums = 0;
            return false;
        }
        CardCtl.CardTouchPINVerify(pwd);
        if(CardCtl.Status == 0){
            nums = 0;
            return true;
        }else{
            if(CardCtl.Status == -200069){
                nums = 5;
            }if(CardCtl.Status == -200070){
                nums = 4;
            }if(CardCtl.Status == -200071){
                nums = 3;
            }if(CardCtl.Status == -200072){
                nums = 2;
            }if(CardCtl.Status == -200073){
                nums = 1;
            }if(CardCtl.Status == -200074){
                nums = 6;
            }else{
                nums = 0;
                //$.messager.alert("系统消息",cardgeterrmessage(CardCtl.Status),"error");
            }
            return false;
        }
    }catch(e){
        nums = 0;
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        //$.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closeTouchPort();
    }
}
/**
 * 修改接触式密码
 * @param oldPwd
 * @param newPwd
 * @returns {Boolean}
 */
function modifyTouchPwd(oldPwd,newPwd,nums){
    try{
        if(typeof(oldPwd) != "string" || dealNull(oldPwd).length != 6){
            $.messager.alert("系统消息","原密码长度不正确！","error");
            return;
        }
        if(typeof(newPwd) != "string" || dealNull(newPwd).length != 6){
            $.messager.alert("系统消息","新密码长度不正确！","error");
            return;
        }
        var isOpenPortOk = openTouchPort();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardTouchPINVerify(oldPwd);
        if(CardCtl.Status != 0){
            if(CardCtl.Status = -200069){
                nums = 5;
            }else if(CardCtl.Status == -200070){
                nums = 4;
            }else if(CardCtl.Status == -200071){
                nums = 3;
            }else if(CardCtl.Status == -200072){
                nums = 2;
            }else if(CardCtl.Status == -200073){
                nums = 1;
            }else if(CardCtl.Status == -200074){
                nums = 6;
            }else{
                nums = 0;
                $.messager.alert("系统消息",cardgeterrmessage(CardCtl.Status),"error");
            }
            return false;
        }
        CardCtl.CardTouchPINChange(oldPwd,newPwd);
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',"密码修改失败，请重新进行操作！" + cardgeterrmessage(CardCtl.Status),"error");
            return false;
        }
    }catch (e) {
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closeTouchPort();// 关闭端口
    }
}
function modifyTouchPwd2(oldPwd,newPwd){
    try{
        if(typeof(oldPwd) != "string" || dealNull(oldPwd).length != 6){
            $.messager.alert("系统消息","原密码长度不正确！","error");
            return;
        }
        if(typeof(newPwd) != "string" || dealNull(newPwd).length != 6){
            $.messager.alert("系统消息","新密码长度不正确！","error");
            return;
        }
        var isOpenPortOk = openTouchPort();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardTouchPINVerify(oldPwd);
        if(CardCtl.Status != 0){
            $.messager.alert("系统消息","原密码不正确，请重新进行输入！","error");
            return false;
        }
        CardCtl.CardTouchPINChange(oldPwd,newPwd);
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',"密码修改失败，请重新进行操作！" + cardgeterrmessage(CardCtl.Status),"error");
            return false;
        }
    }catch (e) {
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closeTouchPort();// 关闭端口
    }
}
/**
 * 解锁接触式密码
 * @returns {Boolean}
 */
function unLockTouchPwd(){
    try{
        var isOpenPortOk = openTouchPort();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardTouchPINUnLock();
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',"解锁失败，请重新进行操作！" + cardgeterrmessage(CardCtl.Status),"error");
            return false;
        }
    }catch (e) {
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closeTouchPort();// 关闭端口
    }
}

/**
 * 解锁接触式密码
 * @returns {Boolean}
 */
function reSetTouchPwd(newPwd){
    try{
        if(typeof(newPwd) != "string" || dealNull(newPwd).length != 6){
            $.messager.alert("系统消息","新密码长度不正确！","error");
            return;
        }
        var isOpenPortOk = openTouchPort();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardTouchPINReLoad(newPwd);
        if(CardCtl.Status == 0){
            return true;
        }else{
            $.messager.alert('系统消息',"密码重置出现错误，请重新进行操作！" + cardgeterrmessage(CardCtl.Status),"error");
            return false;
        }
    }catch (e) {
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closeTouchPort();// 关闭端口
    }
}

//卡扣款,用于柜面撤销操作,撤销类消费
function writecard_onlydecrease(card_No, indata) {
    try {
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardConsume(1001,card_No + indata);
        if (CardCtl.Status != 0) {
            $.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
        return true;
    }catch (e) {
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally {
        closecardctlport();// 关闭端口
    }
}
//左补0
function lpad(string,num){
    var lnum = string.length;
    if(lnum == num){
        return string;
    }
    if(lnum > num){
        return string.substring(0,num -1);
    }
    while(lnum < num){
        string = '0' + string;
        lnum = string.length;
    }
    return string;
}
//获取当前时间
function getDate(){
    var now = new Date();
    var dtstr = now.getFullYear();
    var month = now.getMonth() + 1;
    if (month <= 9){
        dtstr = dtstr + "0" + month;
    }else{
        dtstr = dtstr + "" + month;
    }
    var day = now.getDate();
    if (day <= 9){
        dtstr = dtstr + "0" + day;
    }else{
        dtstr = dtstr +  "" + day;
    }
    var hours = now.getHours();
    if (hours <= 9){
        dtstr = dtstr + "0" + hours;
    }else{
        dtstr = dtstr +  "" + hours;
    }
    var minutes = now.getMinutes();
    if (minutes <= 9){
        dtstr = dtstr + "0" + minutes;
    }else{
        dtstr = dtstr +  "" + minutes;
    }
    var seconds=now.getSeconds();
    if (seconds <= 9){
        dtstr = dtstr + "0" + seconds;
    }else{
        dtstr = dtstr +  "" + seconds;
    }
    return dtstr;
}
//构造充值indata
function getIndata(money){
    var finalstring = "";
    var f = lpad((money * 100) + '',10);
    finalstring = finalstring + f;
    var t = getDate();
    finalstring = finalstring + t;
    finalstring = finalstring + '0';
    finalstring = finalstring + '123456';
    return finalstring;
}
//构造充值indata
function getOutdata(money){
    var finalstring = "";
    var f = lpad((money * 100) + '',10);
    finalstring = finalstring + f;
    var t = getDate();
    finalstring = finalstring + t;
    finalstring = finalstring + '0';
    finalstring = finalstring + '0';
    return finalstring;
}
//消费
function qwritecard_onlydecrease(cardNo,amt){
    try{
        var isOpenPortOk = openIccPort();
        if(!isOpenPortOk){
            return false;
        }
        var abd = getOutdata(amt);
        ICCInterCtl.ICC_Consume(1001,cardNo + abd);
        if (ICCInterCtl.Status == 0) {
            return true;
        }else {
            alert(ICCInterCtl.Status + ' error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "\n";
        }
        alert(errMsg);
        return false;
    }finally{
        closeIccPort();// 关闭端口
    }
}
function eatsd(){
    //alert(lpad('123456',8));
    alert(getIndata(88));
}
String.prototype.isCHS = function (i) {
    if (this.charCodeAt(i) > 255 || this.charCodeAt(i) < 0 || this.charCodeAt(i) == 183) {
        return true;
    } else {
        return false;
    }
};
//将字符串拆成字符，并存到数组中
String.prototype.strToChars = function () {
    var chars = new Array();
    for (var i = 0; i < this.length; i++) {
        chars[i] = [this.substr(i, 1), this.isCHS(i)];
    }
    String.prototype.charsArray = chars;
    return chars;
};
// 截取字符串（从start字节到end字节）
String.prototype.subCHString = function (start, end) {
    var len = 0;
    var str = "";
    this.strToChars();
    for (var i = 0; i < this.length; i++) {
        if (this.charsArray[i][1]) {
            len += 2;
        } else {
            len++;
        }
        if (end < len) {
            return str;
        } else {
            if (start < len) {
                str += this.charsArray[i][0];
            }
        }
    }
    return str;
};

/**
 * 卡片应用日期修改
 * @param cardNo     充值卡号
 * @param indata     传入字符串
 * @returns {Boolean}充值是否成功
 */
function wirtecard_UpdateDate(cardNo,indata){
    try{
        var isOpenPortOk = opencardctlport();
        if(!isOpenPortOk){
            return false;
        }
        CardCtl.CardModifyCardInfo(7001,cardNo + indata);
        if (CardCtl.Status == 0) {
            return true;
        }else {
            //$.messager.alert('系统消息',cardgeterrmessage(CardCtl.Status),'error');
            return false;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally{
        closecardctlport();// 关闭端口
    }
}

/**
 * 获取pos主密钥卡
 * @param pwd
 * @returns {Boolean}
 */
function cardReadPosCard(){
    var poscardinfo = new Array(4);
    poscardinfo["errMsg"] = "";
    try {
        CardCtl.CardReadPosCard("123456");// 非接触式卡片信息，返回3F00信息
        if(CardCtl.Status == 0){
            poscardinfo['bizid'] = CardCtl.Outdata.subCHString(0,15).trim();//商户编号
            poscardinfo['issuedate'] = CardCtl.Outdata.subCHString(15,29).trim();//发行日期
            poscardinfo['posvardvalue'] = CardCtl.Outdata.subCHString(29,61).trim();//主密钥值
        }else{
            poscardinfo["errMsg"] = cardgeterrmessage(CardCtl.Status);
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        poscardinfo["errMsg"] = errMsg;
    }finally {
        closecardctlport();// 关闭端口
    }
    return poscardinfo;
}


/**
 * 制作pos主密钥卡
 * @param merchantId
 * @param dealdate
 * @param posvalue
 */
function  makeposcard(merchantId,dealdate,posvalue){
    try{
        var indata = merchantId+dealdate+posvalue;
        CardCtl.CardMakePosCard(indata);
        var errmsg;
        if (CardCtl.Status == 0) {
            errmsg = 0;
        }else {
            errmsg = CardCtl.Status;
        }
        return errmsg;
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return errMsg;
    }finally{
        closecardctlport();// 关闭端口
    }
}


/**
 * 获取pos主密钥卡
 * @param pwd
 * @returns {Boolean}
 */
function cardReadPosCard(){
    var poscardinfo = new Array(4);
    poscardinfo["errMsg"] = "";
    try {
        CardCtl.CardReadPosCard("123456");// 非接触式卡片信息，返回3F00信息
        if(CardCtl.Status == 0){
            poscardinfo['bizid'] = CardCtl.Outdata.subCHString(0,15).trim();//商户编号
            poscardinfo['issuedate'] = CardCtl.Outdata.subCHString(15,29).trim();//发行日期
            poscardinfo['posvardvalue'] = CardCtl.Outdata.subCHString(29,61).trim();//主密钥值
        }else{
            poscardinfo["errMsg"] = cardgeterrmessage(CardCtl.Status);
        }
    }catch(e){
        errMsg = "";
        for(i in e){
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        poscardinfo["errMsg"] = errMsg;
    }finally {
        closecardctlport();// 关闭端口
    }
    return poscardinfo;
}
/*********************************************************************
函数说明：往密码键盘中下载工作密钥。
输入值：  DesType，0表示单DES，1表示3DES（默认值为1）
               MainKeyNo，主密钥号，取值0~7（默认值为0）
               UserKeyNo，工作密钥号，取值0~1（默认填0）
UserKey，工作密钥密文（单DES 16个字节，3DES 32个字节）
输出值：  无
返回值：  =0表示成功；
               <0表示失败。
***********************************************************************/
function cardDownloadUserKey(workKey){
    try{
        CardCtl.CardDownloadUserKey(1,0,0,workKey);
        //alert(CardCtl.Status);
        if (CardCtl.Status == 0) {
            return true;
        }else {
            return false;
        }
    }catch(e){
        errMsg = "";
        for (i in e) {
            errMsg += i + ":" + eval("e." + i) + "<br/>";
        }
        if(dealNull(errMsg) == ""){
            errMsg = e.toString();
        }
        $.messager.alert('系统消息',errMsg,'error');
        return false;
    }finally{
        //closecardctlport();// 关闭端口
    }
}
