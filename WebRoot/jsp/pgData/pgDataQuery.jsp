<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	$(function(){
		$("#import_dialog2").dialog({
			title : "导入数据",
			width : 400,
		    height : 185,
		    modal: true,
		    closed : true,
			onClose : function(){
			},
			onBeforeOpen : function(){
				$("#file")[0].value = "";
			}
		});

		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			optimize:true
		},"name");
		
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			optimize:true,
			minLength:"1"
		},"certNo");

		$("#state").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"人员未发送"},
				{value:"1", text:"人员待发送"},
				{value:"2", text:"卡片未发送"},
				{value:"3", text:"卡片已发送"},
				{value:"8", text:"人员发送失败"},
				{value:"9", text:"卡片发送失败"}
			],
			editable:false
		});
		
		$("#dg").datagrid({
			url:"pgData/pgDataAction!getAllPgData.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:false,
			frozenColumns:[[
				{field:"DEAL_NO", checkbox:true},
				{field:"CUSTOMER_ID",title:"人员编号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ST_PERSON_ID",title:"省厅人员编号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.13)}
			]],
			columns:[[
				{field:"CARD_NO",title:"卡号",sortable:true,width:"200px"},
				{field:"CARD_STATE",title:"卡状态",sortable:true},
				{field:"CLSJ",title:"处理时间",sortable:true},
				{field:"STATE",title:"状态",sortable:true, formatter:function(v, r, i){
					if(v == 0){
						return "人员未发送";
					} else if(v == 1){
						return "人员待发送";
					} else if(v == 2){
						return "卡片未发送";
					} else if(v == 3){
						return "卡片已发送";
					} else if(v == 8){
						return "人员发送失败";
					} else if(v == 9){
						return "卡片发送失败";
					}
					return v;
				}},
				{field:"NOTE",title:"备注",sortable:true, width:parseInt($(this).width()*1)}
			]],
			onBeforeLoad:function(params){
				if(!params.query){
					return false;
				}
			},
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            }
		});
		
	})
	
	function query() {
		var params = getformdata("searchConts");
		params.query = true;
		$("#dg").datagrid("load", params);
	}
		
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！","error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		query();
	}
	
	function sendPerson(){
		var selections = $("#dg").datagrid("getSelections");
		if(selections.length != 1){
			$.messager.alert("系统消息","请选择一条记录","warning");
			return;
		}
		if(selections[0].STATE >= 3){
			$.messager.confirm("消息提示", "人员已发送，确定要重发人员信息吗？", function(r){
				if(r){
					$.messager.progress({text:"数据处理中..."});
					$.post("pgData/pgDataAction!sendPerson.action", {certNo:selections[0].CERT_NO}, function(data){
						$.messager.progress("close");
						if (data.status == 1) {
							$.messager.alert("消息提示", data.errMsg, "error");
						} else {
							$.messager.alert("消息提示", "发送成功", "info");
						}
					}, "json");
				}
			});
		} else {
			$.messager.progress({text:"数据处理中..."});
			$.post("pgData/pgDataAction!sendPerson.action", {certNo:selections[0].CERT_NO}, function(data){
				$.messager.progress("close");
				if (data.status == 1) {
					$.messager.alert("消息提示", data.errMsg, "error");
				} else {
					$.messager.alert("消息提示", "发送成功", "info");
				}
			}, "json");
		}
	}
	
	function sendCard(certNo){
		$.messager.progress({text:"数据处理中..."});
		$.post("pgData/pgDataAction!sendCard.action", {certNo:certNo}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error");
			} else {
				$.messager.alert("消息提示", "发送成功", "info");
			}
		}, "json");
	}
	
	function sendCards(certNos){
		$.messager.progress({text:"数据处理中..."});
		$.post("pgData/pgDataAction!batchSendCard.action", {certNo:certNos}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error", function(){
					$("#import_dialog2").dialog("close");
				});
			} else {
				var hasFailItem = false;
            	var msg = "";
				if(data.msgList && data.msgList.length > 0){
    				hasFailItem = true;
					var array = data.msgList;
					for(var i in array){
						msg += "证件号码:<span style='color:red'>" + array[i].certNo + "</span>, 失败原因: <span style='color:red'>" + array[i].failMsg + "</span><br>";
					}
				}
    			if(hasFailItem){
    				$.messager.confirm("消息提示", "操作成功，共 " + data.count + " 条数据， 成功 " + data.succNum + " 条， 有失败的数据, 点击确定查看", function(r){
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
    						    	$("#import_dialog2").dialog("close");
    	        	            	//$("#dg").datagrid("reload");
    						    }
    						});
    						$("#cardbindwin").show();
    					}
    				});
    			} else {
    				$.messager.alert("消息提示","操作成功，共 " + data.count + " 条数据， 成功 " + data.succNum + "", "info", function(){
    					$("#import_dialog2").dialog("close");
    					//$("#dg").datagrid("reload");
    				});
    			}
			}
		}, "json");
	}
	
	function batchSendCard(){
		var selections = $("#dg").datagrid("getSelections");
		if(selections.length == 1){
			sendCard(selections[0].CERT_NO);
		} else if(selections.length > 1) {
			var certNos = "";
			for(var i in selections){
				certNos += selections[i].CERT_NO + "|";
			}
			if(certNos.length > 1) {
				certNos = certNos.substring(0, certNos.length - 1);			
				sendCards(certNos);
			}
		} else {
			$.messager.alert("消息提示", "请选择需要发送的数据", "warning");
		}
	}
	
	function openDialog2(){
		$("#import_dialog2").dialog("open");
	}
	function importCorp() {
		var val = $("#file").val();
		if(!val){
			jAlert("请选择导入文件", "warning");
			return;
		}
		$.messager.progress({text:"数据处理中，请稍候..."});
		$.ajaxFileUpload({  
            url:"pgData/pgDataAction!batchImportSendCard.action",
            fileElementId:['file'],
            dataType:"json",
            success: function(data, status){
            	$.messager.progress("close");
            	
            	var hasFailItem = false;
            	var msg = "";
            	if(data.status == '0'){
        			if(data.msgList && data.msgList.length > 0){
        				hasFailItem = true;
    					var array = data.msgList;
    					for(var i in array){
    						msg += "证件号码:<span style='color:red'>" + array[i].certNo + "</span>, 失败原因: <span style='color:red'>" + array[i].failMsg + "</span><br>";
    					}
    				}
        			if(hasFailItem){
        				$.messager.confirm("消息提示", "操作成功，共 " + data.count + " 条数据， 成功 " + data.succNum + " 条， 有失败的数据, 点击确定查看", function(r){
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
        						    	$("#import_dialog2").dialog("close");
        						    	//$("#dg").datagrid("reload");
        						    }
        						});
        						$("#cardbindwin").show();
        					}
        				});
        			} else {
        				$.messager.alert("消息提示","操作成功，共 " + data.count + " 条数据， 成功 " + data.succNum + "", "info", function(){
        					$("#import_dialog2").dialog("close");
        					//$("#dg").datagrid("reload");
        				});
        			}
            	}else{
            		$.messager.alert('消息提示',data.errMsg,'error', function(){
            			$("#import_dialog2").dialog("close");
            			//$("#dg").datagrid("reload");
            		});
            	}
            }
        });
	}
	function downloadTemplate2(){
		$("#import_dialog2").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=batchSendCard");
	}
	
	function pgPersonUpdate(){
		var selections = $("#dg").datagrid("getSelections");
		if(!selections || selections.length != 1){
			jAlert("请选择一条记录", "warning");
			return;
		}
		var certNo = selections[0].CERT_NO;
		$.messager.progress({text:"数据处理中..."});
		$.post("pgData/pgDataAction!updatePerson.action", {certNo:certNo}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error");
			} else {
				$.messager.alert("消息提示", "操作成功！", "info");
			}
		}, "json");
	}
</script>
<n:initpage title="发送省厅人员信息、卡信息进行查询！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input  id="certNo" type="text" class="textinput" name="certNo" /></td>
						<td class="tableleft">姓名：</td>
						<td class="tableright"><input id="name" type="text" name="name" class="textinput"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright">
							<input id="cardNo" type="text" class="textinput" name="cardNo"/>
							&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
						</td>
						<td class="tableleft">状态：</td>
						<td class="tableright"><input  id="state" type="text" class="textinput" name="state" /></td>
					</tr>
					<tr>
						<td class="tableleft">处理时间：</td>
						<td class="tableright" colspan="3">
							<input id="beginTime" type="text" name="startDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
							&nbsp;&nbsp;——&nbsp;&nbsp;
							<input id="endTime" type="text"  name="endDate" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
						<td class="tableleft" colspan="5" style="padding-right: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-reload'" href="javascript:void(0);" class="easyui-linkbutton" onclick="pgPersonUpdate()">人员信息变更</a>
							<a href="javascript:void(0);" class="easyui-menubutton" iconCls="icon-checkInfo" data-options="menu:'#mm1'" plain="false" onclick="javascript:void(0)">发送数据</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-import'" href="javascript:void(0);" class="easyui-linkbutton" onclick="openDialog2()">导入数据</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<div id="mm1" style="width:50px;display: none;">
			<div data-options="iconCls:'icon-userCuteDayBal'" onclick="javascript:sendPerson()">人员数据</div>
			<div class="menu-sep"></div>
			<div data-options="iconCls:'icon-cardService'" onclick="javascript:batchSendCard()">卡片数据</div>
		</div>
  		<table id="dg" title="发送省厅数据"></table>
  		<div id="import_dialog2" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	  		<table width="100%">
				<tr>
					<td>
						<input id="file" name="file" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
						<button onclick="importCorp()">导入</button>
					</td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate2()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
  		</div>
  		<div id="cardbindwin"></div>
  	</n:center>
</n:initpage>