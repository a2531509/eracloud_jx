<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<style type="text/css">
	.label_left{text-align:right;padding-right:2px;height:30px;font-weight:700;padding-right:5px;}
	.label_right{text-align:left;padding-left:2px;height:30px;padding-left:5px;}
	#tb table,#tb table td{border:1px dotted rgb(149, 184, 231);}
	#tb table{border-left:none;border-right:none;}
	body{font-family:'微软雅黑'}
</style> 
<script type="text/javascript">
	var cardinfo;
	var currentCard = "";
	$(function(){
		createSysCode({
			id:"certType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		createSysCode({
			id:"csex",
			codeType:"SEX",
			isShowDefaultOption:false
		});
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
	});
	function readCard(){
		$.messager.progress({text:"正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			jAlert("读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error",function(){
				window.history.go(0);
			});
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		validCard();
	}
	function validCard(){
		$.post("cardService/cardServiceAction!getFjmkSaleInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				if(dealNull(data.card.cardNo).length == 0 || data.status != "0"){
					jAlert("验证卡片信息发生错误：非个性化卡采购信息不存在！","error",function(){
						window.history.go(0);
					});
				}
				$("#cardType").val(data.cardTypeStr);
				if(data.card.saleState == "<%=com.erp.util.Constants.SALE_STATE.WXS%>"){
					$("#saleStateStr").val("未销售");
				}else if(data.card.saleState == "<%=com.erp.util.Constants.SALE_STATE.YXS%>"){
					$("#saleStateStr").val("已销售");
				}
				$("#saleState").val(data.card.saleState);
				$("#busType").val(data.busTypeStr);
				if(dealNull(data.person.certNo) != ""){
					$("#certType").combobox("setValue",data.person.certType);
					$("#certNo").val(data.person.certNo);
					$("#name").val(data.person.name);
					$("#csex").combobox("setValue",data.person.gender);
				}
				if(data.isGoodCard != ""){
					var tempchg = "[" + data.isGoodCard + "]";
					tempchg = eval("(" + tempchg +  ")");
					$("#costFee").combobox({
						width:174,
						data:tempchg,
						valueField:"codeValue",
						editable:false,
					    textField:"codeName",
					    panelHeight:"auto",
                        onLoadSuccess:function(rows){
                           $(this).combobox("select",rows[0].codeValue);
                        }
					});
				}
				currentCard = data.card.cardNo;
			}else{
				jAlert("验证卡信息时出现错误，请重试...","error",function(){
					window.history.go(0);
				});
			}
		},"json").error(function(){
			jAlert("验证卡信息时出现错误，请重试...","error",function(){
				window.history.go(0);
			});
		});
	}
	function queryCard(){
		if(dealNull($("#cardNo").val()).length != 20){
			jAlert("输入的卡号不正确！请仔细核对卡片信息并重新输入！<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>","warning");
			return;
		}
		$.messager.progress({text:"正在验证卡信息,请稍后..."});
		validCard();
	}
	function tijiao(){
		if(currentCard != $("#cardNo").val()){
            jAlert("卡号已被修改，请重新进行读卡或查询，再进行销售！","warning");
			return;
		}
		if($("#cardNo").val().replace(/\s/g,"") == ""){
            jAlert("请先进行读卡或查询以获卡信息！","warning");
			return;
		}
		if($("#saleState").val() != "<%=com.erp.util.Constants.SALE_STATE.WXS%>"){
            jAlert("该卡不是未销售状态，不能进行销售！","warning");
            return;
        }
        var exp = /^\d+(\.?\d{1,2})?$/g;
        if(!exp.test($("#costFee").combobox("getValue"))){
            jAlert("选择工本费金额不正确，请重新进行选择！","warning",function(){
                $("#costFee").combobox("showPanel");
            });
            return;
        }
        if(isNaN($("#costFee").combobox("getValue"))){
            jAlert("选择工本费金额不正确，请重新进行选择！","warning",function(){
                $("#costFee").combobox("showPanel");
            });
            return;
        }

        //记名信息
        if(dealNull($("#certType").combobox("getValue")) == ""){
            jAlert("请选择记名人证件类型！","warning",function(){
                $("#certType").combobox("showPanel");
            });
            return;
        }
        if(dealNull($("#certNo").val()) == ""){
            jAlert("请输入记名人证件号码！","warning",function(){
                $("#certNo").focus();
            });
            return;
        }
        if(dealNull($("#name").val()) == ""){
            jAlert("请输入记名人姓名！","warning",function(){
                $("#name").focus();
            });
            return;
        }
        if(dealNull($("#csex").combobox("getValue")) == "" || dealNull($("#csex").combobox("getValue")) == "0"){
            jAlert("请选择记名人性别！","warning",function(){
                $("#csex").combobox("showPanel");
            });
            return;
        }
        //1.记名证件类型
        var jmcertnoType = $("#certType").combobox("getValue");
        if(dealNull(jmcertnoType) == ""){
        	jmcertnoType = "00";
        }else if(dealNull(jmcertnoType) == "1"){
        	jmcertnoType = "00";
        }else if(dealNull(jmcertnoType) == "2"){
        	jmcertnoType = "05";
        }else if(dealNull(jmcertnoType) == "3"){
        	jmcertnoType = "01";
        }else if(dealNull(jmcertnoType) == "4"){
        	jmcertnoType = "02";
        }else if(dealNull(jmcertnoType) == "5"){
        	jmcertnoType = "04";
        }else if(dealNull(jmcertnoType) == "6"){
        	jmcertnoType = "05";
        }else{
        	jmcertnoType = "05";
        }
        //tensileStringByByte(以字节长度)等同于java版的字符串补位Tools.tensileString(string,len,pre,addStr);
        jmcertnoType = tensileStringByByte(jmcertnoType,2,true,0);
        //记名证件号码
        var jmcertno = $("#certNo").val();
        jmcertno = tensileStringByByte(jmcertno,32,false," ");
        //记名姓名
        var jmcertName = $("#name").val();
        jmcertName = tensileStringByByte(jmcertName,20,false," ");
        //记名性别
        var jmCsex = $("#csex").combobox("getValue");
		$.messager.confirm("系统消息","您确定要销售卡号为【" + $("#cardNo").val() + "】的单芯片卡吗？",function(is) {
			if(is && modifypersonalinfo($("#cardNo").val(),jmcertName,jmcertno,jmcertnoType,jmCsex)){//
				$.messager.progress({text:"正在进行处理，请稍后...."});
				$.post("cardService/cardServiceAction!saveFjmkSale.action",$("#fjmkSingleSale").serialize(),function(data,status){
					if(status == "success"){
						if(data.status != "0"){
							$.messager.progress("close");
							jAlert(data.errMsg,"error");
						}else if(data.status == "0"){
							$.messager.progress("close");
                            showReport("单芯片卡销售",data.dealNo,function(){
                                window.history.go(0);
                            });
						}
					}else{
						$.messager.progress("close");
						jAlert("销售请求出现错误，请重试！","error");
					}
				},"json").error(function(){
					$.messager.progress("close");
					jAlert("销售请求出现错误，请重试！","error");
				});
			}
		});
	}
    function readIdCard1(){
        $.messager.progress({text:"正在获取证件信息，请稍后...."});
        var o = getcertinfo();
        if(dealNull(o["name"]).length == 0){
            $.messager.progress("close");
            return;
        }
        $.messager.progress("close");
        $("#certType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
        $("#certNo").val(o["cert_No"]);
        $("#name").val(o["name"]);
        var charc = "";
        if(dealNull(o["cert_No"]).length == 18){
            charc = o["cert_No"].substring(16,17);
            if(charc % 2 == 0){
                $("#csex").combobox("setValue","2");
            }else{
                $("#csex").combobox("setValue","1");
            }
        }
    }
    function readIdCard2(){
        $.messager.progress({text:'正在获取证件信息，请稍后....'});
        var o = getcertinfo();
        if(dealNull(o["name"]).length == 0){
            $.messager.progress("close");
            return;
        }
        $.messager.progress("close");
        $("#agtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
        $("#agtCertNo").val(o["cert_No"]);
        $("#agtName").val(o["name"]);
    }
</script>
<n:initpage title="单芯片卡进行销售操作，<span style='color:red'>注意</span>：只有未销售的单芯片卡才能进行销售操作！">
	<n:center>
		<form id="fjmkSingleSale" class="datagrid-toolbar" style="height:100%;width:100%;">
			<input id="saleState" name="saleState" type="hidden" value=""/>
            <div id="tb" style="padding:2px 0;" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:true,tools:'#toolspanel'" title="单芯片卡销售">
                <table cellpadding="0" cellspacing="0" id="toolpanel" style="width:100%">
                    <tr>
                        <td width="22%" align="right" class="label_left">卡号：</td>
                        <td width="25%" align="left" class="label_right"><input name="cardNo" data-options="required:true,invalidMessage:'请读卡以获取卡号信息',missingMessage:'请读卡以获取卡号信息'" class="textinput easyui-validatebox" id="cardNo" type="text" maxlength="20"/></td>
                        <td width="10%" align="right" class="label_left">卡类型：</td>
                        <td class="label_right">
                            <input id="cardType" type="text" class="textinput" name="cardType" readonly="readonly" disabled="disabled"/>
                            <a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="readCard()">读卡</a>
                            <a  data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton"    onclick="queryCard()">查询</a>
                        </td>
                    </tr>
                    <tr>
                        <td align="right" class="label_left">销售状态：</td>
                        <td class="label_right"><input id="saleStateStr" type="text" class="textinput" name="saleStateStr"  readonly="readonly" disabled="disabled"/></td>
                        <td align="right" class="label_left">公交类型：</td>
                        <td class="label_right"><input id="busType" type="text" class="textinput" name="busType" readonly="readonly" disabled="disabled"/></td>
                    </tr>
                    <tr>
                        <td colspan="4" style="height:30px;">&nbsp;</td>
                    </tr>
                </table>
                <h3 class="subtitle">记名信息</h3>
                <table cellpadding="0" cellspacing="0" id="toolpanel" style="width:100%">
                    <tr>
                        <td width="22%" align="right" class="label_left">证件类型：</td>
                        <td width="25%" class="label_right"><input id="certType" type="text" class="textinput" name="rec.certType"/></td>
                        <td width="10%" align="right" class="label_left">证件号码：</td>
                        <td class="label_right"><input id="certNo" type="text" class="textinput" name="rec.certNo" maxlength="18"/></td>
                    </tr>
                    <tr>
                        <td align="right" class="label_left">姓名：</td>
                        <td class="label_right"><input id="name" type="text" class="textinput" name="rec.customerName" maxlength="10"/></td>
                        <td align="right" class="label_left">性别：</td>
                        <td class="label_right">
                            <input name="csex"  class="textinput" id="csex" type="text"/>
                            <a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard1()">读身份证</a>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4" style="height:30px;">&nbsp;</td>
                    </tr>
                </table>
                <h3 class="subtitle">工本费</h3>
                <table cellpadding="0" cellspacing="0" id="toolpanel" style="width:100%">
                    <tr>
                        <td width="22%" align="right" class="label_left">工本费：</td>
                        <td width="25%" class="label_right"><input id="costFee" type="text" class="textinput" name="costFee"/></td>
                        <td width="10%" align="right" class="label_left">&nbsp;</td>
                        <td class="label_right">&nbsp;</td>
                    </tr>
                    <tr>
                        <td colspan="4" style="height:30px;">&nbsp;</td>
                    </tr>
                </table>
                <h3 class="subtitle">代理人信息</h3>
                <table class="tablegrid">
                    <tr>
                        <td width="22%" align="right" class="label_left">代理人证件类型：</td>
                        <td width="25%" class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="textinput" value="1"/> </td>
                        <td width="10%" align="right" class="label_left">代理人证件号码：</td>
                        <td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" validtype="idcard"  maxlength="18"/></td>
                    </tr>
                    <tr>
                        <td align="right" class="label_left">代理人姓名：</td>
                        <td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput"/></td>
                        <td align="right" class="label_left">代理人联系电话：</td>
                        <td class="tableright">
                            <input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/>
                            <a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align:center;height:40px;" colspan="4"><a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="tijiao()">保存</a></td>
                    </tr>
                </table>
            </div>
        </form>
	</n:center>
</n:initpage>