<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<base href="<%=basePath%>">
<title>Insert title here</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		$("#import_dialog").dialog({
			title : "导入数据",
			width : 400,
		    height : 185,
		    modal: true,
		    closed : true,
			onClose : function(){
			},
			onBeforeOpen : function(){
				$("#excel")[0].value = "";
			}
		});
		$("#import_dialog2").dialog({
			title : "导入数据",
			width : 400,
		    height : 185,
		    modal: true,
		    closed : true,
			onClose : function(){
			},
			onBeforeOpen : function(){
				$("#excel2")[0].value = "";
			}
		});
		
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
		
		$("#bank_dialog").dialog({
			title: '授权文件导出银行',    
		    width: 250,
		    height: 150,
		    closed: true,
		    modal: true,
		    onClose:function(){
		    	$("#exportBankId").combobox("setValue", "");
		    },
		    buttons:[
		    	{text:"保存", iconCls:"icon-ok", handler:function(){
		    		var bankId = $("#exportBankId").combobox("getValue");
		    		if(!bankId){
		    			jAlert("请选择导出银行", "warning");
		    			return;
		    		}
		    		
		    		var selection = $("#dg").datagrid("getSelections");
		    		
		    		if(selection.length == 0){
		    			$.messager.alert("系统消息", "请选择导出数据", "warning", function(){
		    				$("#dg").datagrid("clearSelections");
		    			});
		    			return;
		    		}
		    		
		    		var reqJsonData = new Array();
		    		
		    		for(var i in selection){
		    			reqJsonData.unshift({id:{subCardNo:selection[i].SUB_CARD_NO, certNo:selection[i].CERT_NO}, bankId:bankId});
		    		}
		    		
		    		$.messager.progress({
		    			text:"数据处理中, 请稍候..."
		    		});
		    		
		    		$('#downloadcsv').attr('src',"cardService/cardBindBankCardAction!exportBindInfo.action?reqJsonData=" + JSON.stringify(reqJsonData));
		    		
		    		startCycle();
		    		
		    		$("#bank_dialog").dialog("close");
		    	}},
		    	{
		    		text:"取消", iconCls:"icon-cancel", handler:function(){
		    			$("#bank_dialog").dialog("close");
		    		}
		    	}
		    ]
		    
		});
		
		$('body').append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
		
		createSysCode({
			id:"state",
			codeType:"CARD_BIND_BANKCARD_STATE"
		});
		
		createSysBranch({id:"brchId",isJudgePermission:false}); 
		
		$("#bankId").combobox({
			url:"cardService/cardBindBankCardAction!getCurrentBrchBanks.action",
			valueField:"bankId",
			textField:"bankName",
			panelHeight: '200',
			loadFilter:function(data){
				return data.rows;
			}
		});
		
		$("#exportBankId").combobox({
			url:"cardService/cardBindBankCardAction!getCurrentBrchBanks.action",
			valueField:"bankId",
			textField:"bankName",
			panelHeight: '200',
			loadFilter:function(data){
				return data.rows;
			}
		});
		
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:"1"
		},"corpName");
		
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:"1"
		},"corpId");
		
		$("#dg").datagrid({
			url : "cardService/cardBindBankCardAction!getCardBindBankCardInfos.action",
			pagination : true,
			fit : true,
			toolbar : $("#tb"),
			pageList : [20, 50, 100, 200, 500],
			striped : true,
			border : false,
			rownumbers : true,
			showFooter : true,
			fitColumns : true,
			frozenColumns : [ [
			    {field:"", checkbox:true},
				{field:"NAME", title:"姓名", sortable:true, width : parseInt($(this).width() * 0.08)},
				{field:"CERT_NO", title:"证件号码", sortable:true, width : parseInt($(this).width() * 0.15)},
				{field:"CARD_NO", title:"市民卡卡号", sortable:true, width : parseInt($(this).width() * 0.15)},
				{field:"CARD_STATE", title:"市民卡状态", sortable:true, width : parseInt($(this).width() * 0.1), formatter:function(value){
					if(value == '1'){
						return "正常";
					} else if(value == '2'){
						return "临时挂失";
					} else if (value == '3'){
						return '书面挂失';
					}
				}},
				{field:"STATE", title:"绑定状态", sortable:true, width : parseInt($(this).width() * 0.1), formatter:function(value){
					if(value == '0'){
						return "已导出";
					} else if(value == '1'){
						return "已绑定未开通圈存";
					} else if (value == '2'){
						return '自主圈存';
					} else if (value == '3') {
						return '自主圈存 + 实时圈存';
					} else {
						return "<span style='color:orange'>未绑定</span>";
					}
				}}
			]],
			columns:[[
				{field:"SUB_CARD_NO", title:"社保卡号", sortable:true},
				{field:"BANK_NAME", title:"绑定银行", sortable:true},
				{field:"BANK_CARD_NO", title:"银行账号", sortable:true},
				{field:"BIND_DATE", title:"绑定日期", sortable:true},
				{field:"BRCH_NAME", title:"办理网点", sortable:true},
				{field:"USER_ID", title:"办理柜员", sortable:true}
			]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', data.errMsg, 'warning');
				}
			},
			onBeforeLoad : function(param){
				if(!param["load"]){
					return false;
				}
				
				return true;
			}
		});
	})
	
	function openModalDialog(title, icon, url, callback) {
		$.modalDialog({
			title : title,
			iconCls : icon,
			maximized : true,
			shadow : false,
			closable : false,
			maximizable : false,
			href : url,
			onDestroy : function() {
				if(callback)
					callback();
			},
			buttons : [{
				text : '保存',
				iconCls : 'icon-save',
				handler : function() { save2(); }
			}, {
				text : '取消',
				iconCls : 'icon-cancel',
				handler : function() {
					$.modalDialog.handler.dialog('destroy');
					$.modalDialog.handler = undefined;
				}
			} ]
		});
	}
	
	function query(){
		var name = $("#name").val();
		var certNo = $("#certNo").val();
		var cardNo = $("#cardNo").val();
		var corpId = $("#corpId").val();
		var corpName = $("#corpName").val();
		
		if(!name && !certNo && ! cardNo && !corpId && !corpName){
			jAlert("人员信息和单位信息不能都为空", "warning");
			return;
		}
		
		$("#dg").datagrid("load", {
			"bindInfo.name":name,
			"bindInfo.id.certNo":certNo,
			"card.cardNo":cardNo,
			"bindInfo.state":$("#state").combobox("getValue"),
			"bindInfo.brchId":$("#brchId").combotree("getValue"),
			"bindInfo.bankId":$("#bankId").combobox("getValue"),
			startDate:$("#startDate").val(),
			endDate:$("#endDate").val(),
			"person.corpCustomerId":corpId,
			"person.corpName":corpName,
			load:true
		});
	}
	
	function bind(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length != 1){
			$.messager.alert("系统消息", "请选择一条记录", "warning", function(){
				$("#dg").datagrid("clearSelections");
			});
			return;
		}
		
		if(selection[0].STATE > 0){
			$.messager.alert("系统消息", "卡片 [" + selection[0].CARD_NO + "] 已绑定银行卡 [" + selection[0].BANK_CARD_NO + "].", "warning", function(){
				$("#dg").datagrid("clearSelections");
			});
			return;
		}
		
		if(selection[0].CARD_STATE != 1){
			$.messager.alert("系统消息", "卡片 [" + selection[0].CARD_NO + "] 状态不正常, 不能进行绑定操作", "warning", function(){
				$("#dg").datagrid("clearSelections");
			});
			return;
		}
		
		openModalDialog("绑定银行卡", "icon-taskExpBank", "cardService/cardBindBankCardAction!toCardBindBankCardIndex.action?card.cardNo=" + selection[0].CARD_NO);
	}
	
	function unbind(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length != 1){
			$.messager.alert("系统消息", "请选择一条记录", "warning", function(){
				$("#dg").datagrid("clearSelections");
			});
			return;
		}
		
		if(selection[0].STATE < 1){
			$.messager.alert("系统消息", "卡片 [" + selection[0].CARD_NO + "] 未绑定银行卡", "warning", function(){
				$("#dg").datagrid("clearSelections");
			});
			return;
		}
		
		if(selection[0].CARD_STATE != 1){
			$.messager.alert("系统消息", "卡片 [" + selection[0].CARD_NO + "] 状态不正常, 不能进行解绑操作", "warning", function(){
				$("#dg").datagrid("clearSelections");
			});
			return;
		}
		
		$.messager.confirm("系统消息", "确认解绑?", function(r){
			if(r){
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				$.post("cardService/cardBindBankCardAction!cardUnBindBankCard.action", {
						"bindInfo.id.certNo":selection[0].CERT_NO,
						"bindInfo.id.subCardNo":selection[0].SUB_CARD_NO,
						"rec.agtCertType":$("#agtCertType").combobox("getValue"),
						"rec.agtCertNo":$("#agtCertNo").val(),
						"rec.agtName":$("#agtName").val(),
						"rec.agtTelNo":$("#agtTelNo").val()
					}, function(data){
					$.messager.progress('close');
					
					var msg = "";
					if(data.status == "1"){//fail
						msg = data.errMsg;
						$.messager.alert("消息提示", msg, "error");
					} else {
						showReport("银行卡解绑",data.dealNo,function(){
							query();
		     			});
					}
				}, "json");
			}
		});
	}
	
	function exportBindInfo(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(selection.length == 0){
			$.messager.alert("系统消息", "请选择导出数据", "warning", function(){
				$("#dg").datagrid("clearSelections");
			});
			return;
		}
		
		$("#bank_dialog").dialog("open");
	}
	
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	
	function startDetect(){
		commonDwr.isDownloadComplete("exportBindInfoSucc", function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
					query();
				});
			}
		});
		commonDwr.isDownloadComplete("exportBindInfoFail", function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出失败！","error",function(){
					$.messager.progress("close");
				});
			}
		});
	}
	
	function importBind(){
		if($("#excel").val() == ""){
			$.messager.alert("系统消息", "请选择导入文件！", "warning", function(){
				$("#excel").focus();
			});
			return;
		}
		var fileName = $("#excel").val();
		if(fileName.substring(fileName.length-4) != ".xls"){
			$.messager.alert("系统消息", "导入文件格式不正确！", "warning", function(){
				$("#excel").focus();
			});
			return;
		}
		$.messager.confirm("消息提示", "确认导入该批量绑定银行卡数据？", function(e){
			if(e){
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				$.ajaxFileUpload({  
		            url:"cardService/cardBindBankCardAction!batchCardBindBankCard.action",
		            secureuri:false,  
		            fileElementId:['excel'],
		            dataType:"json",
		            success: function(data, status){
		            	$.messager.progress("close");
		            	var msg = "";
		            	var hasFailItem = false;
		            	
		            	if(data.status == '0'){
		        			if(data.failList){
		        				hasFailItem = true;
		        				
		        				msg += data.message + "<br>";
		    					
		    					var array = data.failList;
		    					
		    					for(var i in array){
		    						msg += "<p>身份证号:" + array[i].id.certNo + ", 社保卡号:" + array[i].id.subCardNo + ", 失败原因: " + array[i].failReason + "</p>";
		    					}
		    				}
		        			
		        			if(hasFailItem){
		        				$.messager.confirm("消息提示", "操作完成, 有失败的数据, 点击确定查看", function(r){
		        					if(r){
		        						$("#cardbindwin").html(msg);
		        						$("#cardbindwin").window({
		        							title:"失败数据",
		        							width:600,    
		        						    height:400,    
		        						    modal:true,
		        						    collapsible:false,
		        						    minimizable:false,
		        						    maximizable:false,
		        						    onClose:function(){
		        						    	query();
		        						    }
		        						});
		        						$("#cardbindwin").show();
		        					}
		        				});
		        			} else {
		        				$.messager.alert("消息提示","操作成功","info", function(){
		        					query();
		        				});
		        			}
		        			
		            	}else{
		            		$.messager.alert('消息提示',data.errMsg,'error');
		            	}
		            },
		            error: function (data, status, e){
		            	$.messager.alert("消息提示", "网络连接异常, " + status, "error");
		            	$dgview.datagrid('load');
		            }
		        });
			}
		});
	}
	
	function readCard() {
		$.messager.progress({text : '正在验证卡信息,请稍后...'});
		var cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert('系统消息','读卡出现错误，请重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error');
			return false;
		}
		var cardNo = cardinfo["card_No"];
		
		$("#cardNo").val(cardNo);
		query();
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
	
	function batchUnbind(){
		if($("#excel2").val() == ""){
			$.messager.alert("系统消息", "请选择导入文件！", "warning", function(){
				$("#excel2").focus();
			});
			return;
		}
		var fileName = $("#excel2").val();
		$.messager.confirm("消息提示", "确认导入该批量绑定银行卡数据？", function(e){
			if(e){
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				$.ajaxFileUpload({  
		            url:"cardService/cardBindBankCardAction!batchCardUnBindBankCard.action",
		            secureuri:false,  
		            fileElementId:['excel2'],
		            dataType:"json",
		            success: function(data, status){
		            	$.messager.progress("close");
		            	var msg = "";
		            	var hasFailItem = false;
		            	if(data.status == '0'){
		        			if(data.failList){
		        				hasFailItem = true;
		        				msg += data.message + "<br>";
		    					var array = data.failList;
		    					for(var i in array){
		    						msg += "<p>身份证号:" + array[i].id.certNo + ", 社保卡号:" + array[i].id.subCardNo + ", 失败原因: " + array[i].failReason + "</p>";
		    					}
		    				}
		        			
		        			if(hasFailItem){
		        				$.messager.confirm("消息提示", "操作完成, 有失败的数据, 点击确定查看", function(r){
		        					if(r){
		        						$("#cardbindwin").html(msg);
		        						$("#cardbindwin").window({
		        							title:"失败数据",
		        							width:600,    
		        						    height:400,    
		        						    modal:true,
		        						    collapsible:false,
		        						    minimizable:false,
		        						    maximizable:false,
		        						    onClose:function(){
		        						    	query();
		        						    }
		        						});
		        						$("#cardbindwin").show();
		        					}
		        				});
		        			} else {
		        				$.messager.alert("消息提示","操作成功","info", function(){
		        					query();
		        				});
		        			}
		        			
		            	}else{
		            		$.messager.alert('消息提示',data.errMsg,'error');
		            	}
		            },
		            error: function (data, status, e){
		            	$.messager.alert("消息提示", "网络连接异常, " + status, "error");
		            	$dgview.datagrid('load');
		            }
		        });
			}
		});
	}
	
	function openDlg(){
		$("#import_dialog").dialog("open");
	}
	
	function downloadTemplate(){
		$("#import_dialog").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=batchApplyImportCorpPerson");
	}
	function openDlg2(){
		$("#import_dialog2").dialog("open");
	}
	
	function downloadTemplate2(){
		$("#import_dialog2").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=batchUnbind");
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin: 2px 0">
			<span class="badge">提示</span> <span>在此可以查看<span
				class="label-info"><strong>卡片绑定银行卡信息</strong></span>以及<span
				class="label-info"><strong>绑定/解绑</strong></span>等操作
			</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true"
		style="border-left: none; border-bottom: none; height: auto; overflow: hiddsen;">
		<div id="tb" style="padding: 2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input id="certNo" class="textinput" /></td>
					<td class="tableleft">姓名：</td>
					<td class="tableright"><input id="name" class="textinput" /></td>
					<td class="tableleft">市民卡号：</td>
					<td class="tableright">
						<input id="cardNo" class="textinput" />
						<a style="text-align: center; margin: 0 auto;" data-options="plain:false,iconCls:'icon-readCard'"
							href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a></td>
					<td class="tableleft">绑定状态：</td>
					<td class="tableright"><input id="state" class="textinput" /></td>
				</tr>
				<tr>
					<td class="tableleft">办理网点：</td>
					<td class="tableright">
						<input id="brchId" class="textinput" /></td>
					<td class="tableleft">绑定银行：</td>
					<td class="tableright"><input id="bankId" class="textinput" /></td>
					<td class="tableleft">起始时间：</td>
					<td class="tableright">
						<input id="startDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" /></td>
					<td class="tableleft">结束时间：</td>
					<td class="tableright">
						<input id="endDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" /></td>
				</tr>
				<tr>
					<td class="tableleft">单位编号：</td>
					<td class="tableright"><input id="corpId" class="textinput" /></td>
					<td class="tableleft">单位名称：</td>
					<td class="tableright"><input id="corpName" class="textinput" /></td>
					<td class="tableright" colspan="4">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="query()">查询</a>
						<shiro:hasPermission name="sqglImp">
							&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export" onclick="exportBindInfo()">授权文件导出</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="bindBank">
							&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-taskExpBank" onclick="bind()">绑定</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" onclick="openDlg()">批量导入绑定</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="undoBindBank">
							&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-ljcx" onclick="unbind()">解绑</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" onclick="openDlg2()">批量导入解绑</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="卡片绑定银行卡信息" style="width: 100%"></table>
	</div>
	<div id="test" data-options="region:'south',split:false,border:true" style="height:100px; width:100%;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
	  		<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%;">
	  			<div style="width:100%;display:none;" id="accinfodiv">
		  			<h3 class="subtitle">账户信息</h3>
		  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
				</div>
	  			<h3 class="subtitle">代理人信息</h3>
				 <table width="100%" class="tablegrid">
					 <tr>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="easyui-combobox  easyui-validatebox"  value="1" style="width:174px;"/> </td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" maxlength="18"/></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input id="agtName" name="rec.agtName" type="text" class="textinput easyui-validatebox"   maxlength="30" /></td>
					 	<th class="tableleft">代理人联系电话：</th>
						<td class="tableright"><input name="rec.agtTelNo" id="rec.agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/></td>
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
	<div id="cardbindwin"></div>
	<div id="bank_dialog">
		<div style="margin: 0 auto; width: 80%; padding: 20px 20px">
			<input id="exportBankId" class="textinput" />
		</div>
	</div>
    <div id="import_dialog" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	  	<table width="100%">
			<tr>
				<td>
					<input id="excel" name="uploadFile" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
					<button onclick="importBind()">导入</button>
				</td>
			</tr>
		</table>
		<br>
		<!-- <a href="javascript:void(0)" onclick="downloadTemplate()">点击此处</a>下载导入模版 -->
		<iframe style="display: none;"></iframe>
  	</div>
  	<div id="import_dialog2" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	 	<table width="100%">
			<tr>
				<td>
					<input id="excel2" name="uploadFile" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
					<button onclick="batchUnbind()">导入</button>
				</td>
			</tr>
		</table>
		<br>
		<a href="javascript:void(0)" onclick="downloadTemplate2()">点击此处</a>下载导入模版
		<iframe style="display: none;"></iframe>
	</div>
</body>
</html>