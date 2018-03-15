<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 卡片换卡 -->
<script type="text/javascript">
	var finalcostfee = "${costFee}";
	var isreadcard = 1;
	var curreadcardno = "";
	var $grid;
	var cardmsg;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		if("${defaultErrMsg}" != ""){
			$.messager.alert("系统消息","${defaultErrMsg}","error");
		}
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		createLocalDataSelect({
			id:"isGoodCard",
			data:[{value:"0",text:"是"},{value:"1",text:"否"}],
			value:"1",
		    onSelect:function(node){
		 		if(node.value == "0"){
		 			$.messager.alert("系统消息","已选择是好卡，请先进行读卡,再进行查询！","warning");
		 		}
		 		$(this).combobox("setValue",node.value);
				$("#isGoodCard").val(node.value);
				$("#cardAmt").val("0.00");
				isreadcard = "1";
				curreadcardno = "";
		 	}
		});
		if("${isGoodCard}" != ""){
			var tempchg = "[" + "${isGoodCard}" + "]";
			tempchg = eval("(" + tempchg +  ")");
			tempchg.unshift({codeName:"请选择", codeValue:""});
			$("#chgCardReason").combobox({
				width:174,
				data:tempchg,
				valueField:"codeValue",
				editable:false,
			    textField:"codeName",
			    panelHeight:"auto",
			    onSelect:function(node){
			    	if(node){
			    		if(!node.codeValue){
			    			$("#costFee").val("");
			    		}else if(node.codeValue == '<s:property value="@com.erp.util.Constants@CHG_CARD_REASON_ZLWT"/>'){
			    			$("#costFee").val("0.00");
			    		}else{
			    			$("#costFee").val(finalcostfee);
			    		}
			    	}
			 	},
			 	onLoadSuccess:function(){
			 		if(!$("#chgCardReason").combobox("getValue")){
		    			$("#costFee").val("");
		    		}else if($("#chgCardReason").combobox("getValue") == '<s:property value="@com.erp.util.Constants@CHG_CARD_REASON_ZLWT"/>') {
			 			$("#costFee").val("0.00");
			 		}else{
			 			$("#costFee").val(finalcostfee);
			 		}
			 	}
			});
		}
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"cardService/cardServiceAction!hkCardQuery.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[ 
				{field:"V_V",checkbox:true},
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.18)},
				{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"GENDERS",title:"性别",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.2)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"CARDSTATE",title:"卡状态",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"START_DATE",title:"启用日期",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"VALID_DATE",title:"有效期",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"BUSTYPE",title:"公交类型",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"CHGFLAG",title:"是否允许换卡",sortable:true,width:parseInt($(this).width() * 0.1)}
				//{field:"COSTFEE",title:"工本费",sortable:true,width:parseInt($(this).width() * 0.08)}
			]],
            onLoadSuccess:function(data){
            	$("input[type=checkbox]").each(function(){
    				this.checked = false;
    			});
        	    if(data.status != 0){
        		    $.messager.alert("系统消息",data.errMsg,"error");
        	    }
        	    if(data.rows.length > 0){
        	    	$(this).datagrid("selectRow",0);
        	    }
        	    $("#form").form("reset");
        	    $("#costFee").val("0.00");
        	    if(isreadcard == 0){
        	    	$("#isGoodCard").combobox("setValue", "0");
        	    }
            },onSelect:function(index,data){
           	    if(data == null)return;
	            $("#accinfo").get(0).src = "jsp/cardService/inneraccinfo.jsp?cardNo=" + data.CARD_NO;
	            if($("#accinfodiv").css("display") != "block"){
		            $("#accinfodiv").show();
	            }
          	}
		});
	});
	function query(){
		if($("#certNo").val().replace(/\s/g,"") == "" && $("#cardNo").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入查询证件号码或是卡号！","error");
			return;
		}
		if($("#isGoodCard").combobox("getValue") == "0" && isreadcard != "0"){
			$.messager.alert("系统消息","是否好卡已选择是【好卡】请先读卡再进行查询！","error");
			return;
		}
		if(curreadcardno != $("#cardNo").val()){
			$("#cardAmt").val("0");
			$("#isGoodCard").combobox("setValue","1")
		}
		if($("#isGoodCard").combobox("getValue") == "1"){
			$("#cardAmt").val("0");
		}
		$grid.datagrid("load",{
			queryType:"0",
			certNo:$("#certNo").val(), 
			cardNo:$("#cardNo").val()
		});
	}
	function toSaveHk(){
		var rows = $grid.datagrid("getChecked");
		if(rows && rows.length == 1){
			if($("#isGoodCard").combobox("getValue") == "0" && isreadcard != "0"){
				$.messager.alert("系统消息","是否好卡已选择是【好卡】，请先读卡再进行操作！","error");
				return;
			}
			if(($("#isGoodCard").combobox("getValue") == "0" && isreadcard == "0") && $("#cardNo").val() != curreadcardno){
				$.messager.alert("系统消息","卡号发生变化，请重新进行查询！","error",function(){
					window.history.go(0);
				});
				return;
			}
			if(rows[0].CHG_FLAG != "0"){
				$.messager.alert("系统消息","换卡发生错误：此卡类型设置参数不允许进行换卡！","error");
				return;
			}
			if(rows[0].CARD_STATE != '<s:property value="@com.erp.util.Constants@CARD_STATE_ZC"/>'){
				$.messager.alert("系统消息","换卡发生错误：卡状态不正常！当前状态【" + rows[0].CARDSTATE + "】" + '<span style="color:red">&nbsp;&nbsp;提示：换卡老卡必须是正常状态</span>',"error");
				return;
			}
			var finalconfirmmsg = "";
			finalconfirmmsg = finalconfirmmsg + "您确定要对【" + rows[0].NAME + "】卡号为【" + rows[0].CARD_NO + "】的卡进行换卡吗？<br/>";
			finalconfirmmsg = finalconfirmmsg + "<div style=\"color:red;margin-left:42px;\">提示：1、换卡时老卡将进行注销<br/>";
			finalconfirmmsg = finalconfirmmsg + "2、换卡工本费：" + $("#costFee").val() + "<br/>";
			finalconfirmmsg = finalconfirmmsg + "3、是否好卡：已选择 " + $("#isGoodCard").combobox("getText") + "<br/>";
			finalconfirmmsg = finalconfirmmsg + "4、卡面余额：" + ($("#isGoodCard").combobox("getValue") == "0" ? $("#cardAmt").val() : "以后台为准");
			finalconfirmmsg = finalconfirmmsg + "</div>";
			$.messager.confirm("系统消息",finalconfirmmsg,function(is){
				if(is){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("cardService/cardServiceAction!saveBhk.action",$("#form").serialize() + "&cardNo=" + rows[0].CARD_NO + "&queryType=1&cardAmt=" + $("#cardAmt").val(),function(data,status){
						$.messager.progress("close");
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info":"error"),function(){
							if(data.status == "0"){
								showReport("卡片换卡",data.dealNo);
								$grid.datagrid("reload");
								$("#form").form("reset");
							}
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条记录信息进行换卡","error");
		}
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
		isreadcard = 0;
		curreadcardno = cardmsg["card_No"];
		$("#isGoodCard").combobox("setValue","0");
		$("#chgCardReason").combobox("setValue",'<s:property value="@com.erp.util.Constants@CHG_CARD_REASON_QT"/>');
		query();
	}
	function readIdCard(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#certNo").val(o["cert_No"]);
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
<n:initpage title="卡片进行换卡操作！<span style='color:red;'>注意：</span>1、只有卡状态处于【正常】状态的卡才能进行换卡；2、换卡时老卡将自动进行注销；3、老卡账户余额可待指定工作日后，通过’换卡转钱包’转入新卡。">
	<n:center>
		<div id="tb">
			<form id="searchFrom">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" maxlength="18"/></td>
						<td class="tableright">卡号：</td>
						<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" maxlength="20"/></td>
						<td class="tableleft">卡余额：</td>
						<td class="tableright"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" value="0.00" readonly="readonly"/></td>
						<td style="padding-left:3px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="query()">查询</a>
							<shiro:hasPermission name="changecardsave">
								<a href="javascript:void(0);"  class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-ok'" onclick="toSaveHk();">确定</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="用户信息"></table>
    </n:center>
 	<div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
  		<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%">
  			<div style="width:100%;display:none;" id="accinfodiv">
	  			<h3 class="subtitle">账户信息</h3>
	  			<iframe name="accinfo" id="accinfo" width="100%" style="border:none;padding:0px;margin:0px;"></iframe>
			</div>
			<table class="tablegrid">
				<tr>
			 	 	<td colspan="8">
			  			<h3 class="subtitle" style="border:none">卡片信息</h3>
			 	 	</td>
			 	</tr>
			 	<tr>
			 	 	<td class="tableleft">是否好卡：</td>
					<td class="tableright"><input name="isGoodCard" id="isGoodCard" value="1" class="textinput" type="text"/></td>
			 	 	<td class="tableleft">换卡原因：</td>
					<td class="tableright"><input id="chgCardReason" type="text"  class="textinput" name="rec.chgCardReason" /> </td>
			 	 	<td class="tableleft">工本费：</td>
					<td class="tableright" colspan="3"><input id="costFee" type="text" value="" class="textinput" name="costFee" readonly="readonly" /><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
			 	</tr>
			 	<tr>
			 	 	<td colspan="8">
			  			<h3 class="subtitle" style="border:none">代理人信息</h3>
			 	 	</td>
			 	</tr>
				<tr>
					<td class="tableleft">代理人姓名：</td>
					<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
					<td class="tableleft">代理人证件类型：</td>
					<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox  easyui-validatebox" name="rec.agtCertType" value="1" style="width:174px;"/> </td>
					<td class="tableleft">代理人证件号码：</td>
					<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard" maxlength="18"/></td>
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