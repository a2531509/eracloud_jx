<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 卡片补卡 -->
<script type="text/javascript">
	var costFee = "${costFee}";
	var $grid;
	$(function(){
		if("${defaultErrMsg}" != ""){
			$.messager.alert("系统消息","${defaultErrMsg}","error",function(){
				window.history.go(0);
			});
		}
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			isShowDefaultOption:true
		});
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		createLocalDataSelect({
			id:"costFee",
			data:${costFeeSelect}
		});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
			//minLength:"1"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"cardService/cardServiceAction!bkCardQuery.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
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
				{field:"REISSUEFLAG",title:"是否允许补卡",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"COSTFEE",title:"工本费",sortable:true,width:parseInt($(this).width() * 0.08)}
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
        	    $("#costFee").combobox("select", costFee);
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
		$grid.datagrid("load",{
			queryType:"0",
			certNo:$("#certNo").val(), 
			cardType:$("#cardType").combobox("getValue"),
			cardNo:$("#cardNo").val()
		});
	}
	function saveCardLos(){
		var row = $grid.datagrid("getSelected");
		if(row){
			if(row.REISSUE_FLAG != "0"){
				$.messager.alert("系统消息","补卡发生错误：此卡类型设置参数不允许进行补卡！","error");
				return;
			}
			if(row.CARD_STATE != '<s:property value="@com.erp.util.Constants@CARD_STATE_GS"/>'){
				$.messager.alert("系统消息","补卡发生错误：此卡不是挂失状态！当前状态【" + row.CARDSTATE + "】" + '<span style="color:red">&nbsp;&nbsp;提示：补卡老卡必须是书面挂失状态</span>',"error");
				return;
			}
			$.messager.confirm("系统消息","您确定要对【" + row.NAME + "】卡号为【" + row.CARD_NO + "】的卡进行补卡吗？<br/><div style='color:red;margin-left:42px;'>提示：1、补卡时老卡将进行注销<br/>2、补卡工本费：" + $("#costFee").combobox("getValue") + "</div>",function(is){
				if(is){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("cardService/cardServiceAction!saveBhk.action",$("#form").serialize() + "&cardNo=" + row.CARD_NO + "&queryType=0",function(data,status){
						$.messager.progress("close");
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info":"error"),function(){
							if(data.status == "0"){
								showReport("卡片补卡",data.dealNo);
								$grid.datagrid("reload");
								$("#form").form("reset");
							}
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条记录信息进行补卡","error");
		}
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
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
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
	if("<%=com.erp.util.Constants.ENTER_TO_QUERY%>" == "0"){
		$(document).keypress(function(e){
			if(e.keyCode == 13){
				query();
			}
		});
	}
</script>
<n:initpage title="卡片进行补卡操作！<span style='color:red;'>注意：</span>1、只有卡状态处于书面挂失状态的卡才能进行补卡；2、补卡时老卡将自动进行注销；3、老卡账户余额可待指定工作日后，通过’换卡转钱包’转入新卡。">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="searchFrom">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" maxlength="18"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" maxlength="20"/></td>
						<td style="padding-left:5px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="query()">查询</a>
							<shiro:hasPermission name="cardfillbk">
								<a href="javascript:void(0);"  class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-ok'" plain="false" onclick="saveCardLos();">确定</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="用户信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
  		<form id="form" method="post" class="datagrid-toolbar" style="height:100%">
  			<div style="width:100%;display:none;" id="accinfodiv">
	  			<h3 class="subtitle">账户信息</h3>
	  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
			</div>
  			<h3 class="subtitle">代理人信息</h3>
			<table class="tablegrid">
			 	 <tr>
			 	 	<td class="tableleft">工本费：</td>
					<td class="tableright"><input id="costFee" name="costFee" type="text" class="textinput" /><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
					<td class="tableleft">代理人证件类型：</td>
					<td class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="easyui-combobox" value="1" style="width:174px;"/> </td>
					<td class="tableleft">代理人证件号码：</td>
					<td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" validtype="idcard"  maxlength="18"/></td>
			 	 </tr>
				 <tr>
					<td class="tableleft">代理人姓名：</td>
					<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
				 	<td class="tableleft">代理人联系电话：</td>
					<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/></td>
					<td style="text-align:center;" colspan="2">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
						<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
					</td>
				</tr>
			</table>
		</form>	
	</div>
</n:initpage>