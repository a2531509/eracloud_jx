<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%> 
<%@include file="/layout/initpage.jsp" %> 
<script type="text/javascript"> 
	var $grid;
	var oldCardNo = "";
	var cardinfo
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST %>",
			isShowDefaultOption:true
		});
		$grid = createDataGrid({
			id:"dg",
			url:"pwdservice/pwdserviceAction!payPwdQuery.action",
			fit:true,pagination:false,rownumbers:true,striped:true,fitColumns:true,autoRowHeight:true,scrollbarSize:0,singleSelect:true,
			columns:[[
		       	{field:"V_V",title:"",sortable:true,checkbox:true},
		    	{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width()*0.05)},
		    	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.05)},
		    	{field:"GENDER",title:"性别",sortable:true,width:parseInt($(this).width()*0.05)},
		    	{field:"CERT_TYPE",title:"证件类型",sortable:true,width:parseInt($(this).width()*0.05)},
		    	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width()*0.05)},
		    	{field:"CARD_STATE",title:"卡状态",sortable:true,width:parseInt($(this).width()*0.05)},
		    	{field:"BUS_TYPE",title:"公交类型",sortable:true,width:parseInt($(this).width()*0.05)},
		    	{field:"START_DATE",title:"启用日期",sortable:true,width:parseInt($(this).width()*0.05)}
			]],toolbar:"#tb",
            onLoadSuccess:function(data){
        	    if(data.status != 0){
        		    $.messager.alert("系统消息",data.errMsg,"error");
        	    }else if(data.rows.length > 0){
        		    $(this).datagrid("selectRow",0);
        	    }
            },
            onSelect:function(index,data){
            	if(data == null)return;
	            $("#accinfo").get(0).src = "jsp/cardService/inneraccinfo.jsp?cardNo=" + data.CARD_NO;
	            if($("#accinfodiv").css("display") != "block"){
		            $("#accinfodiv").show();
	            }
            }
		});
	});
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		validCard();
	}
	function validCard(){
		$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				if(dealNull(data.card.cardNo).length == 0){
					$.messager.alert("系统消息","验证卡片错误，卡号信息不存在，该卡不能进行联机账户密码修改。","error",function(){
						window.history.go(0);
					});
				}else{
					$("#cardType").combobox("setValue",dealNull(data.card.cardType));
					oldCardNo = data.card.cardNo;
					query();
				}
			}else{
				$.messager.alert("系统消息","验证卡信息时出现错误，请重试...","error",function(){
					window.history.go(0);
				});
			}
		},"json");
	}
	function query(){
		deteteGridAllRows("dg");
		if($("#cardNo").val().replace(/\s/g,"") == "" && $("#certNo").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请先进行读卡，以获取卡片信息！","error");
			return;
		}
		$("#form").form("reset");
		$grid.datagrid("reload",{
			queryType:"0",
			cardType:$("#cardType").combobox("getValue"),
			cardNo:$("#cardNo").val(),
			certNo:$("#certNo").val()
		});
	}
	function getOldPwd(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			if(dealNull(rows[0].CARD_NO) == ""){
				jAlert("卡号为空，无法读取密码！","warning");
				return;
			}
			if(dealNull(rows[0].CARD_NO).length < 20){
				jAlert("勾选记录的卡号的位数不正确！","warning");
				return;
			}
			$("#oldPwd").val(getEnPin(1,rows[0].CARD_NO));
		}else{
			jAlert("请勾选一条卡记录信息！","warning");
			return;
		}
	}
	function getNewPwd(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			if(dealNull(rows[0].CARD_NO) == ""){
				jAlert("卡号为空，无法读取密码！","warning");
				return;
			}
			if(dealNull(rows[0].CARD_NO).length < 20){
				jAlert("勾选记录的卡号的位数不正确！","warning");
				return;
			}
			$("#pwd").val(getEnPin(1,rows[0].CARD_NO));
			$("#confirmPwd").val(getEnPin(2,rows[0].CARD_NO));
		}else{
			jAlert("请勾选一条卡记录信息！","warning");
			return;
		}
	}
	function submitForm(){
		var curRow = $grid.datagrid("getSelected");
		if(!curRow){
			$.messager.alert("系统消息","请至少选择一条记录进行${ACC_KIND_NAME_LJ }支付密码修改！","error");
			return;
		}
		//已选择记录
		if($("#oldPwd").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入原密码！","error");
			return;
		}
		if($("#pwd").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入新密码！","error");
			return;
		}
		if($("#confirmPwd").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入确认密码！","error");
			return;
		}
		if($("#pwd").val().replace(/\s/g,"") != $("#confirmPwd").val().replace(/\s/g,"")){
			$.messager.alert("系统消息","新密码和确认密码不相同！请重新输入！","error");
			$("#confirmPwd").val("");
			$("#confirmPwd").focus();
			return;
		}
		$.messager.confirm("系统消息","您确定要修改卡号为【" + curRow.CARD_NO + "】的${ACC_KIND_NAME_LJ }支付密码吗？",function(is){
			if(is){
				$.messager.progress({text : "数据处理中，请稍后...."});
				var reqpara = "cardNo=" + curRow.CARD_NO + "&pwd=" + $("#pwd").val() + "&rec.agtCertType=" + $("#agtCertType").combobox("getValue") + "&oldPwd=" + $("#oldPwd").val();
				reqpara += "&rec.agtCertNo=" + $("#agtCertNo").val() + "&rec.agtName=" + $("#agtName").val() + "&rec.agtTelNo=" + $("#agtTelNo").val();
				$.post("pwdservice/pwdserviceAction!savePayPwdModify.action",reqpara,function(data,status){
					$.messager.progress("close");
					if(status == "success"){
						if(data.status == "0"){
							showReport("${ACC_KIND_NAME_LJ }支付密码修改",data.dealNo,function(){
								window.history.go(0);
							});
						}else{
							$.messager.alert("系统消息",data.msg,"error");
						}
					}else{
						$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }密码修改失败！","error");
					}
				},"json");
			}
		});
	}
	function readCard(){
		$.messager.progress({text:"正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		validCard();
	}
	function readIdCard2(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType").combobox("setValue",'1');
		$("#agtCertNo").val(certinfo["cert_No"]);
		$("#agtName").val(certinfo["name"]);
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
<n:initpage title="个人${ACC_KIND_NAME_LJ }支付密码</strong>进行修改操作！<span style='color:red;font-weight:700'>注意：</span>如果原密码不存在，请进行${ACC_KIND_NAME_LJ }支付密码重置！</span>">
	<n:center>
		<div id="tb">
			<table class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" maxlength="18"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" style="width:174px;"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright" style="width:17%"><input name="cardNo" class="textinput" id="cardNo" type="text" maxlength="20"/></td>
						<td style="padding-left:2px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="savePayPwdModify">
								<a  href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-ok'"  onclick="submitForm()">确定</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
		</div>
  		<table id="dg" title="卡信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;overflow:hidden;border-left:none;border-bottom:none;">
  		<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%">
	  		<div style="width:100%;display:none;" id="accinfodiv">
	  			<h3 class="subtitle">账户信息</h3>
	  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
			</div>
	  		<h3 class="subtitle">密码信息</h3>
			<table style="width:100%;" class="tablegrid">
				<tr>
					<th class="tableleft">原密码：</th>
					<td class="tableright">
						<input id="oldPwd" type="password" class="textinput" name="oldPwd" maxlength="6" readonly="readonly"/>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton" onclick="getOldPwd()">密码输入</a>
					</td>
				 	<th class="tableleft">新密码：</th>
					<td class="tableright"><input id="pwd" type="password" class="textinput" name="pwd" maxlength="6" readonly="readonly"/></td>
					<th class="tableleft">确认密码：</th>
					<td class="tableright"><input name="confirmPwd" class="textinput" id="confirmPwd" type="password" maxlength="6" readonly="readonly"/></td>
					<td class="tableleft"><a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="getNewPwd()">密码输入</a></td>
				</tr>
				<tr>
					<td colspan="7"><h3 class="subtitle">代理人信息</h3></td>
				</tr>
				<tr>
					<th class="tableleft">代理人证件类型：</th>
					<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox" name="rec.agtCertType" value="1"/></td>
					<th class="tableleft">代理人证件号码：</th>
					<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard" maxlength="18"/></td>
					<th class="tableleft">代理人姓名：</th>
					<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput" maxlength="30"/></td>
					<td class="tableleft"><a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a></td>
				</tr>
				<tr>
				 	<th class="tableleft">代理人联系电话：</th>
					<td class="tableright" colspan="5"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox" validtype="mobile" maxlength="11"/></td>
					<td class="tableleft">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
					</td>
				</tr>
			</table>
		</form>			
	</div>
</n:initpage>
