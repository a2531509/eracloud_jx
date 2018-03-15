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

		$("#dia").dialog({
    		title:"账户余额回退明细",
    		fit:true,
    		closed:true,
    		border:false,
    		modal:true,
    		onBeforeOpen:function(){
    			var selections = $("#dg").datagrid("getSelections");
    			if(selections.length != 1){
    				$.messager.alert("系统消息","请选择一条记录","warning");
    				return false;
    			}
	    		var dealNo = selections[0].DEAL_NO;
    			$("#dg2").datagrid("load", {dealNo:dealNo});
    		}
    	});
		
		createRegionSelect({id:"regionId"});
		
		$("#state").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			data:[
				{value:"", text:"请选择"},
				{value:"1", text:"已导入"},
				{value:"2", text:"回退中"},
				{value:"0", text:"回退完成"}
			],
			editable:false
		});
		
		$("#dg").datagrid({
			url:"recharge/rechargeAction!accBalReturnQuery.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:true,
			columns:[[
				{field:"", checkbox:true},
				{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"RETURN_DATE",title:"回退日期",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"NUM",title:"总人数",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"AMT",title:"总金额",sortable:true,width:parseInt($(this).width()*0.1), formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"RETURN_NUM",title:"回退成功人数",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"RETURN_AMT",title:"回退成功金额",sortable:true,width:parseInt($(this).width()*0.1), formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"BRCH_NAME",title:"回退网点",sortable:true,width:parseInt($(this).width()*0.2)},
				{field:"USER_NAME",title:"回退柜员",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"STATE",title:"状态",sortable:true,width:parseInt($(this).width()*0.1), formatter:function(v, r, i){
					if(r.MAX_STATE == 0){
						return "回退完成";
					} else if(r.MAX_STATE == 1 && r.MIN_STATE == 0){
						return "回退中";
					} else {
						return "已导入";
					}
					return v;
				}}
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
		
		$("#dg2").datagrid({
			url:"recharge/rechargeAction!accBalReturnDetail.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb2",
			pageList:[50, 100, 200, 500, 1000],
			singleSelect:true,
			frozenColumns:[[
				{field:"DEAL_NO", checkbox:true},
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"BANK_CARD_NO",title:"银行卡号",sortable:true,width:parseInt($(this).width()*0.15)}
			]],
			columns:[[
				{field:"REMAIN_BAL",title:"留存金额",sortable:true, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"ACC_BAL",title:"账户余额",sortable:true, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"RETURN_BAL",title:"回退金额",sortable:true,formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"AFTER_ACC_BAL",title:"回退后账户余额",sortable:true, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"STATE",title:"状态",sortable:true, formatter:function(v){
					if(v == 0){
						return "<span style='color:green'>已回退</span>";
					} else if(v == 1){
						return "<span style='color:orange'>未回退</span>";
					}
					return v;
				}},
				{field:"BANK_NAME",title:"银行",sortable:true},
				{field:"BANK_ADDR",title:"开户银行",sortable:true},
				{field:"NOTE",title:"备注",sortable:true,width:parseInt($(this).width()*0.08)}
			]],
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
		
	function doReturn(){
		var selections = $("#dg").datagrid("getSelections");
		if(selections.length != 1){
			$.messager.alert("系统消息","请选择一条记录","warning");
			return;
		}
		var dealNo = selections[0].DEAL_NO;
		$.messager.progress({text:"数据处理中..."});
		$.post("recharge/rechargeAction!doReturn.action", {dealNo:dealNo}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error");
			} else {
				$.messager.alert("消息提示", "回退成功", "info");
			}
		}, "json");
	}
	
	function viewInfo(){
		$("#dia").dialog("open");
	}
	
	function openDialog2(){
		$("#import_dialog2").dialog("open");
	}

	function downloadTemplate2(){
		$("#import_dialog2").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=accBalReturnTemplate");
	}
	
	function importData() {
		var val = $("#file").val();
		if(!val){
			jAlert("请选择导入文件", "warning");
			return;
		}
		$.messager.progress({text:"数据处理中，请稍候..."});
		$.ajaxFileUpload({  
            url:"recharge/rechargeAction!importAccBalReturnData.action",
            fileElementId:['file'],
            dataType:"json",
            success: function(data, status){
            	$.messager.progress("close");
            	if(data.status == '1'){
            		jAlert("导入数据失败，" + data.errMsg, "warning");
        			return;
            	}
            	$("#import_dialog2").dialog("close");
            	query();
            }
        });
	}
	
	function exportReturnData (){
		var selections = $("#dg").datagrid("getSelections");
		if(selections.length != 1){
			$.messager.alert("系统消息","请选择一条记录","warning");
			return;
		}
		var dealNo = selections[0].DEAL_NO;
		$("#import_dialog2").children("iframe").attr("src", "recharge/rechargeAction!exportReturnData.action?dealNo=" + dealNo);
	}
	
	function deleteData(){
		var selections = $("#dg").datagrid("getSelections");
		if(selections.length != 1){
			$.messager.alert("系统消息","请选择一条记录","warning");
			return;
		} else if(selections[0].MIN_STATE == 0){
			$.messager.alert("系统消息","记录已有回退数据，不能删除","warning");
			return;
		}
		var dealNo = selections[0].DEAL_NO;
		$.messager.progress({text:"数据处理中..."});
		$.post("recharge/rechargeAction!deleteAccBalReturnData.action", {dealNo:dealNo}, function(data){
			$.messager.progress("close");
			if (data.status == 1) {
				$.messager.alert("消息提示", data.errMsg, "error");
			} else {
				$.messager.alert("消息提示", "操作成功", "info", function(){
					query();
				});
			}
		}, "json");
	}
</script>
<n:initpage title="车改资金回退数据进行查询！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">流水号：</td>
						<td class="tableright"><input  id="dealNo" type="text" class="textinput" name="dealNo" /></td>
						<td class="tableleft">回退起始日期：</td>
						<td class="tableright"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">回退结束日期：</td>
						<td class="tableright"><input name="endTime"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">回退状态：</td>
						<td class="tableright"><input  id="state" type="text" class="textinput" name="state" /></td>
					</tr>
					<tr>
						<td class="tableleft" colspan="8" style="padding-right: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" plain="false" onclick="viewInfo()">预览</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="openDialog2()">导入</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back" plain="false" onclick="doReturn()">回退</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-export" plain="false" onclick="exportReturnData()">导出</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false" onclick="deleteData()">删除</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="车改资金回退数据"></table>
  	</n:center>
  	<div id="dia" >
  		<div id="tb2" class="tablegrid">
  			<!-- <a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-add'" onclick="reSendCardData()">数据补发</a> -->
  		</div>
       	<table id="dg2" style="width:100%"></table>
  	</div>
  	<div id="import_dialog2" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	  	<table width="100%">
			<tr>
				<td>
					<input id="file" name="file" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
					<button onclick="importData()">导入</button>
				</td>
			</tr>
		</table>
		<br>
		<a href="javascript:void(0)" onclick="downloadTemplate2()">点击此处</a>下载导入模版
		<iframe style="display: none;"></iframe>
  	</div>
</n:initpage>