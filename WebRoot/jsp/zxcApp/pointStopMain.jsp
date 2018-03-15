<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<%--自行车应用终止 --%>
<script type="text/javascript">
    var $grid;
    var cardmsg;
    var isNeedAutoConfirmOrCancel = false;
    var writeCardSum = 0;
    $(function(){
        $(document).keypress(function(event){
            if(event.keyCode == 13){
                query();
            }
        });
        var bodys = document.getElementsByTagName("body");
        bodys[0].onunload = function(){
            if(isNeedAutoConfirmOrCancel){
            	toDealCardAppHjl("","1");
            }
        };
        createSysCode({
            id:"agtCertType",
            codeType:"CERT_TYPE",
            value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
        });
        createSysCode({
            id:"cardType",
            codeType:"CARD_TYPE",
            hasDownArrow:false,
            value:" "
        });
        createSysCode({
            id:"cardState",
            codeType:"CARD_STATE",
            hasDownArrow:false,
            value:" "
        });
        createSysCode({
            id:"busType",
            codeType:"BUS_TYPE",
            hasDownArrow:false,
            value:" "
        });
        createSysCode({
            id:"personalGender",
            codeType:"SEX",
            value:" ",
            hasDownArrow:false
        });
        createSysCode({
            id:"personalCertType",
            codeType:"CERT_TYPE",
            value:" ",
            hasDownArrow:false
        });
        $grid = createDataGrid({
            id:"dg",
            url:"cardService/cardServiceAction!cardAppOpenQuery.action",
            fit:true,
            pagination:false,
            rownumbers:true,
            border:false,
            striped:true,
            singleSelect:true,
            fitColumns:true,
            scrollbarSize:0,
            columns:[[
               {field:"APP_TYPE",title:"应用编号",sortable:true,width:parseInt($(this).width() * 0.06)},
               {field:"APPTYPE",title:"应用类型",sortable:true,width:parseInt($(this).width() * 0.06)},
               {field:"OPEN_DATE",title:"开通日期",sortable:true,width:parseInt($(this).width() * 0.08)},
               {field:"VALID_DATE",title:"有效期",sortable:true,width:parseInt($(this).width() * 0.08)},
               {field:"OPENFEE",title:"费用",sortable:true,width:parseInt($(this).width() * 0.05)},
               {field:"STATESTR",title:"状态",sortable:true,width:parseInt($(this).width() * 0.04),formatter:function(value,row,index){
                    if(row.STATE != "0"){
                        return "<span style='color:red;'>" + value + "</span>";
                    }else{
                        return "<span style='color:green'>" + value + "</span>";
                    }
                }},
               {field:"LAST_MODIFY_DATE",title:"最后操作时间",sortable:true,width:parseInt($(this).width() * 0.12)},
               {field:"ACPTORGNAME",title:"受理机构",sortable:true,width:parseInt($(this).width() * 0.1)},
               {field:"ACPTID",title:"受理点",sortable:true,width:parseInt($(this).width() * 0.1)},
               {field:"USER_ID",title:"操作员/终端编号",sortable:true,width:parseInt($(this).width() * 0.1)},
               {field:"END_DEAL_NO",title:"终端流水",sortable:true,width:parseInt($(this).width() * 0.1)}
            ]],
            onLoadSuccess:function(data){
                if(data.status != 0){
                    if(data.execSql == "0"){
                        $.messager.alert("系统消息","未找到当前卡片已开通的应用信息！","warning");
                    }else{
                        $.messager.alert("系统消息",data.errMsg,"error");
                    }
                }
                if(typeof(data.card) != "undefined"){
                    $("#cardState").combobox("setValue",data.card.cardState);
                    $("#cardType").combobox("setValue",data.card.cardType);
                    $("#busType").combobox("setValue",data.card.busType);
                    $("#issueDate").val(data.card.issueDate);
                    $("#cardNo2").val(data.card.cardNo);
                }
                if(typeof(data.bp) != "undefined"){
                    $("#personalName").val(data.bp.name);
                    $("#personalGender").combobox("setValue",(dealNull(data.bp.gender) == "" ? "9" : data.bp.gender));
                    $("#personalCertType").combobox("setValue",(dealNull(data.bp.certType) == "" ? "1" : data.bp.certType));
                    $("#personalCertNo").val(data.bp.certNo);
                }
                if(data.rows.length > 0){
                    $grid.datagrid("selectRow",0);
                }
                //此处不要reset表单
            }
        });
        $("#cardNo").focus();
    });
    function query(){
    	if(!$("#searchFrom").form("validate")){
    		$("#cardNo").focus();
    		return false;
    	}
        if($("#cardNo").val().replace(/\s/g,"") == ""){
            $.messager.alert("系统消息","请输入查询证件号码或是卡号！","warning",function(){
            	$("#cardNo").focus();
            });
            return;
        }
        $("#cardNo2").val("");
        writeCardSum = 0;
        $grid.datagrid("load",{
            queryType:"0",
            cardNo:$("#cardNo").val()
        });
    }
    /**
     *appType 暂定  01 广电，02 自来水，03 电力，04 过路过桥，05 自行车，06 移动，07 公园年卡，08 积分宝，09 新自行车
     */
    function saveCardAppClose(){
    	var curRows = $grid.datagrid("getChecked");
    	if(!curRows || curRows.length <= 0){
    		$.messager.alert("系统消息","请勾选一条应用开通信息进行终止！","warning");
    		return false;
    	}
    	if($("#cardNo").val() != $("#cardNo2").val()){
    		$.messager.alert("系统消息","卡号已发生变更，请重新进行查询再进行应用终止！","warning");
    		return false;
    	}
        if($("#cardNo2").val() == ""){
            $.messager.alert("系统消息","卡号已发生变更，请重新进行查询再进行应用终止！","warning",function(){});
            return false;
        }
        var finalconfirmmsg = "";
        finalconfirmmsg = finalconfirmmsg + "您确定要为【" + $("#personalName").val() + "】卡号为【" + $("#cardNo2").val() + "】的卡<span style='color:red;font-weight:600;'>终止</span>【" + curRows[0].APPTYPE + "】应用吗？";
        $.messager.confirm("系统消息",finalconfirmmsg,function(is){
            if(is){
                $.messager.progress({text:"正在进行应用终止，请稍后...."});
                if(dealNull(curRows[0].APP_TYPE) != "09"){
                    $.post("cardService/cardServiceAction!saveCardAppOpenOrClose.action", $("#form").serialize() + "&queryType=1&rec.rsvTwo=" + curRows[0].APP_TYPE,function(data,status){
                        if(status == "success"){
                            if (data.status == "0"){
                                showReport("应用终止",data.dealNo,function (){
                                	$.messager.progress("close");
                                	query();
                                });
                            }else{
                                $.messager.progress("close");
                                $.messager.alert("系统消息", data.errMsg, "error");
                            }
                        }else{
                            $.messager.progress("close");
                            $.messager.alert("系统消息", "同步应用终止状态失败，请重新进行操作！", "error");
                        }
                    }, "json").error(function (){
                        $.messager.alert("系统消息","请求出现错误，请重新进行操作", "error", function (){
                            window.history.go(0);
                        });
                    });
                }else{
                    cardmsg = getcardinfo();
                    if(dealNull(cardmsg["card_No"]).length == 0){
                        $.messager.progress("close");
                        $.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
                        return;
                    }
                    if(cardmsg["status_zxc"] != "0"){
                        $.messager.progress("close");
                        $.messager.alert("系统消息","获取自行车开通信息出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
                        return;
                    }
                    if(cardmsg["rentalType"] == "00"){
                        $.messager.progress("close");
                        $.messager.alert("系统消息","该卡自行车功能未开通或已终止，无需进行终止操作！","warning");
                        return;
                    }
                    $.post("cardService/cardServiceAction!saveCardAppOpenOrCloseHjl.action",$("#form").serialize() + "&queryType=1&ywlx=1&rec.rsvTwo=" + curRows[0].APP_TYPE + "&costFee=" + curRows[0].OPENFEE,function(data1,status1){
                        if(status1 == "success"){//OPENFEE
                            if(data1.status == "0"){
                                $("#dealNo").val(data1.dealNo);
                                isNeedAutoConfirmOrCancel = true;
                                var retMsg = writecard_openorclosezxc2($("#cardNo").val(),data1.writecarddata,data1.writecarddata2);
                                if(dealNull(retMsg.status) == "0"){
                                    isNeedAutoConfirmOrCancel = false;
                                    toDealCardAppHjl("","0","1");
                                }else{
                                    writeCardNext(data1.writecarddata);
                                }
                            }else{
                                $.messager.alert("系统消息", data1.errMsg, "error", function (){
                                    window.history.go(0);
                                });
                            }
                        }else{
                            $.messager.alert("系统消息", "请求出现错误，请重新进行操作", "error", function (){
                                window.history.go(0);
                            });
                        }
                    }, "json").error(function (){
                        $.messager.alert("系统消息", "请求出现错误，请重新进行操作", "error", function (){
                            window.history.go(0);
                        });
                    });
                }
            }
        });
    }
    function writeCardNext(writecarddata){
        cardmsg = getcardinfo();
        if(dealNull(cardmsg["card_No"]).length == 0 || cardmsg["status_zxc"] != "0"){
            if(writeCardSum < 2){
                $.messager.progress("close");
                $.messager.alert("系统消息", "读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"], "error", function (){
                    $.messager.progress({text:"正在进行应用终止，请稍后...."});
                    writeCardSum++;
                    writeCardNext(writecarddata);
                });
            }else{
                isNeedAutoConfirmOrCancel = false;
                toDealCardAppHjl("","1","1");
            }
        }else if(cardmsg["rentalType"] == "00"){
            isNeedAutoConfirmOrCancel = false;
            toDealCardAppHjl("","0","1");
        }else{
            isNeedAutoConfirmOrCancel = false;
            toDealCardAppHjl("","1","1");
        }
    }
    function showCardAppCloseHjl(){
        if(dealNull($("#cardNo").val()) == ""){
            jAlert("请输入查询卡号！","warning",function(){
                $("#cardNo").focus();
            });
            return;
        }
        $.messager.progress({text:"正在加载，请稍后...."});
        $.modalDialog({
            title:"应用终止灰记录处理",
            iconCls:"icon-viewInfo",
            shadow:false,
            border:false,
            maximized:true,
            shadow:false,
            closable:false,
            maximizable:false,
            href:"/jsp/zxcApp/cardAppHjlMain.jsp?cardNo=" + $("#cardNo").val() + "&tempQueryType=1",
            tools:[{
                iconCls:"icon_cancel_01",
                handler:function(){
                    $.messager.progress("close");
                    $.modalDialog.handler.dialog("destroy");
                    $.modalDialog.handler = undefined;
                }
            }]
        });
    }
    /**
     * 应用终止灰记录处理
     * @param dealNo 灰记录流水 为空时自动处理 非空自动处理
     * @param dealType 处理类型 0 确认 1 取消
     * @param dealType 业务类型 0 开通 1 终止
     */
    function toDealCardAppHjl(dealNo,dealType,ywlx){
        var tempDealNo = "";
        var confirmType = "";
        var targetUrl = "";
        var tipMsg = "";
        if(dealNull(dealType) == "0"){
            tipMsg = "终止确认";
            targetUrl = "cardService/cardServiceAction!saveCardAppOpenOrCloseConfirm.action";
        }else if(dealNull(dealType) == "1"){
            tipMsg = "终止取消";
            targetUrl = "cardService/cardServiceAction!saveCardAppOpenOrCloseCancel.action";
        }else{
            jAlert("操作类型不正确！");
            return;
        }
        if(dealNull(dealNo) == ""){
            tempDealNo = $("#dealNo").val();
            confirmType = "0";
        }else{
            tempDealNo = dealNo;
            confirmType = "1";
        }
        if(dealNull(tempDealNo) == ""){
            jAlert("灰记录流水信息不正确，无法进行" + tipMsg + "！");
            return;
        }
        $.post(targetUrl,{
            "rec.dealNo":tempDealNo,
            "queryType":confirmType,// 0 自动确认  1 手工确认
            "ywlx":ywlx
        },function(data,status){
            if(status == "success"){
                if(data.status == "0"){    
                	if(confirmType == "0"){
                		if(dealNull(dealType) == "0"){
                			//自动确认
                            showReport("应用终止",tempDealNo,function (){
                                window.history.go(0);
                            });
                		}else if(dealNull(dealType) == "1"){
                			//自动取消
                			$.messager.progress("close");
	                        $.messager.alert("系统消息","应用终止失败，请重新进行操作！","error");
                		}
                	}else if(dealNull(confirmType) == "1"){
                		if(dealNull(dealType) == "0"){
                			//手动确认
                			showReport("应用终止",tempDealNo,function (){
                                window.history.go(0);
                            });
                		}else if(dealNull(dealType) == "1"){
                			//手动取消
                			$.messager.progress("close");
	                        $.messager.alert("系统消息","同步应用" + tipMsg + "状态成功！","info");
                		}
                	}
                }else{
                	if(confirmType == "0"){
                		if(dealNull(dealType) == "0"){
                			//自动确认失败
                			$.messager.progress("close");
		                    $.messager.alert("系统消息","同步应用" + tipMsg + "状态失败，" + data.errMsg + "，请进行灰记录【确认】处理！","error");
                		}else if(dealNull(dealType) == "1"){
                			//自动取消失败
		                    $.messager.progress("close");
		                    $.messager.alert("系统消息","同步应用" + tipMsg + "状态失败，" + data.errMsg + "，请进行灰记录【取消】处理！","error");
                		}
                	}else if(dealNull(confirmType) == "1"){
	                    if(dealNull(dealType) == "0"){
	                    	//手动确认失败
	                    	$.messager.progress("close");
		                    $.messager.alert("系统消息","同步应用" + tipMsg + "状态失败，" + data.errMsg,"error");
                		}else if(dealNull(dealType) == "1"){
                			//手动取消失败
                			$.messager.progress("close");
    	                    $.messager.alert("系统消息","同步应用" + tipMsg + "状态失败，" + data.errMsg,"error");
                		}
                	}
                }
            }else{
                $.messager.progress("close");
                $.messager.alert("系统消息","同步应用" + tipMsg + "状态失败，请联系系统管理员！","error");
            }
        },"json").error(function (){
            $.messager.alert("系统消息", "同步应用" + tipMsg + "状态失败，请联系系统管理员！","error",function (){
                window.history.go(0);
            });
        });
    }
    function readCard(){
        $.messager.progress({text:"正在获取卡信息，请稍后...."});
        cardmsg = getcardinfo();
        if(dealNull(cardmsg["card_No"]).length == 0){
            $.messager.progress("close");
            $.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
            return;
        }
        $.messager.progress("close");
        $("#cardNo").val(cardmsg["card_No"]);
        $("#cardAmt").val((parseFloat(isNaN(cardmsg["wallet_Amt"]) ? 0:cardmsg["wallet_Amt"])/100).toFixed(2));
        query();
    }
    function readIdCard2(){
        $.messager.progress({text:"正在获取证件信息，请稍后...."});
        var o = getcertinfo();
        if(dealNull(o["name"]).length == 0){
            $.messager.progress("close");
            return;
        }
        $.messager.progress("close");
        $("#agtCertType").combobox("setValue","1");
        $("#agtCertNo").val(o["cert_No"]);
        $("#agtName").val(o["name"]);
    }
    function readSMK2(){
        $.messager.progress({text:"正在获取证件信息，请稍后...."});
        var queryCertInfo = getcardinfo();
        if(dealNull(queryCertInfo["card_No"]).length == 0){
            $.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
            $.messager.progress('close');
            return;
        }
        $.messager.progress("close");
        $("#agtCertType").combobox("setValue","1");
        $("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
        $("#agtName").val(dealNull(queryCertInfo["name"]));
    }
</script>
<n:initpage title="卡片进行应用终止操作，<span style='color:red;'>注意：</span>只有应用状态处于【正常】状态的应用才能进行应用终止！">
    <n:center>
        <div id="tb" style="padding-left: 0px;padding-right: 0px;margin-left: 0px;margin-right: 0px;">
            <form id="searchFrom">
                <table class="tablegrid">
                    <tr>
                        <td class="tableleft">卡号：</td>
                        <td class="tableright"><input id="cardNo" name="cardNo" class="textinput easyui-validatebox" data-options="required:true" type="text" maxlength="20" /></td>
                        <td class="tableleft">卡余额：</td>
                        <td class="tableright"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" value="0.00" readonly="readonly"/></td>
                        <td style="padding-left:3px;text-align:center;">
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-readCard'" onclick="readCard()">读卡</a>
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'" onclick="query()">查询</a>
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-ok'" onclick="saveCardAppClose();">确定终止</a>
                            <a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'" onclick="showCardAppCloseHjl();">灰记录查询</a>
                        </td>
                    </tr>
                </table>
            </form>
            <table style="width:100%;border-bottom:none;" class="tablegrid">
                <tr>
                    <td colspan="8" style="height:30px;"><h3 class="subtitle" style="border:none">客户基本信息</h3></td>
                </tr>
                <tr>
                    <td class="tableleft">姓名：</td>
                    <td class="tableright"><input id="personalName" name="bp.name" class="textinput textinput2" type="text" readonly="readonly"/></td>
                    <td class="tableleft">性别：</td>
                    <td class="tableright"><input id="personalGender" name="bp.gender"  class="textinput textinput2" type="text" readonly="readonly"/></td>
                    <td class="tableleft">证件类型：</td>
                    <td class="tableright"><input id="personalCertType" name="bp.certType" class="textinput textinput2" type="text" readonly="readonly"/></td>
                    <td class="tableleft">证件号码：</td>
                    <td class="tableright"><input id="personalCertNo" name="bp.certNo" class="textinput textinput2" type="text" readonly="readonly"/></td>
                </tr>
                <tr>
                    <td class="tableleft">卡类型：</td>
                    <td class="tableright"><input id="cardType" name="cardType" class="textinput" type="text" readonly="readonly"/></td>
                    <td class="tableleft">卡状态：</td>
                    <td class="tableright"><input id="cardState" name="cardState" class="textinput" type="text" readonly="readonly"/></td>
                    <td class="tableleft">公交类型：</td>
                    <td class="tableright"><input id="busType" name="busType" class="textinput" type="text" readonly="readonly"/></td>
                    <td class="tableleft">发卡日期：</td>
                    <td class="tableright"><input id="issueDate" name="issueDate" class="textinput" type="text" readonly="readonly"/></td>
                </tr>
            </table>
        </div>
        <table id="dg" title="已开通应用信息"></table>
    </n:center>
    <div data-options="region:'south',split:false,border:true" style="height:200px; width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
        <form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%">
            <input id="cardNo2" name="rec.cardNo" type="hidden" value="">
            <input id="dealNo" name="rec.dealNo" type="hidden" value="">
            <table class="tablegrid">
                <tr>
                    <td class="tableleft">代理人证件类型：</td>
                    <td class="tableright"><input name="rec.agtCertType" id="agtCertType" type="text" class="textinput" value="1" style="width:174px;"/> </td>
                    <td class="tableleft">代理人证件号码：</td>
                    <td class="tableright"><input name="rec.agtCertNo" id="agtCertNo" type="text" class="textinput easyui-validatebox"  validtype="idcard" maxlength="18"/></td>
                    <td class="tableleft">代理人姓名：</td>
                    <td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
                    <td class="tableleft">代理人联系电话：</td>
                    <td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox" maxlength="11" validtype="mobile"/></td>
                </tr>
                <tr>
                    <td class="tableleft" colspan="8">
                        <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
                        <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</n:initpage>