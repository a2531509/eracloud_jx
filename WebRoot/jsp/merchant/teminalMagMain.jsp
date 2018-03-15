<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>商户终端管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		$(function() {
			$("#div_import").dialog({
				title : "商户终端批量导入",
				width : 400,
				height : 153,
				closed : true,
				modal : true,
				closable : false,
				buttons : [
					{text:"取消", iconCls:"icon-cancel", handler:function(){
						$("#div_import").dialog("close");
					}}
				],
				onClose : function(){
					$("#importFile").val("");
				}
			});
			
			$("#merchantName").combobox({
				url:"merchantRegister/merchantRegisterAction!getBizName.action",
	          	valueField: 'merchantId', 
	        	textField: 'merchantName',
	        	mode:"remote",
	        	onBeforeLoad:function(params){
	        		if(params && params["q"]){
	        			params["objStr"] = params["q"];
	        		}
	        	},
	        	loadFilter:function(data){
	        		if(data){
	        			data.unshift({merchantId:"", merchantName:"请选择"});
	        		}
	        		
	        		return data;
	        	}
	       });
			
			 $dg = $("#dg");
				$grid=$dg.datagrid({
					id:"dg",
					toolbar:"#tb",
					url : "/merchantRegister/merchantRegisterAction!queryTermInfo.action",
					pageSize:20,
					width : $(this).width() - 0.1,
					height : $(this).height() - 45,
					pagination:true,
					rownumbers:true,
					border:true,
					fit:true,
					singleSelect:false,
					checkOnSelect:true,
					striped:true,
					autoRowHeight:true,
					frozenColumns:[[
						{field:'ID',title:'id',sortable:true,checkbox:'ture'},
						{field:'END_ID',title:'终端编号',sortable:true,width : parseInt($(this).width() * 0.06)},
						{field:'END_NAME',title:'终端名称',sortable:true,width : parseInt($(this).width() * 0.08)},
						{field:'END_TYPE',title:'终端类型',sortable:true,width : parseInt($(this).width() * 0.05),formatter:function(value,row){
			            	  if(row.END_TYPE == '1'){
			            		  return '人工';
			            	  }else if(row.END_TYPE == '2'){
			            		  return '自助';
			            	  }else{
			            		  return '虚拟终端'; 
			            	  }
			              }},
						{field:'END_STATE',title:'终端状态',sortable:true,width : parseInt($(this).width() * 0.05)},
						{field:'LOGIN_FLAG',title:'签到状态',sortable:true,width : parseInt($(this).width() * 0.05),formatter:function(value,row){
			            	  if(row.LOGIN_FLAG == '0'){
			            		  return '签退';
			            	  }else if(row.LOGIN_FLAG == '1'){
			            		  return '签到';
			            	  }else if(row.LOGIN_FLAG == '2'){
			            		  return '上送';
			            	  }else{
			            		  return '对账';
			            	  }
			            }},
			            {field:'MERCHANT_ID',title:'所属商户编号',sortable:true},
						{field:'MERCHANT_NAME',title:'所属商户',sortable:true},
						{field:'INS_LOCATION',title:'安装位置',sortable:true},
						
					]],
					columns:[[
						{field:'PSAM_NO',title:'人社PSAM卡号',sortable:true,width : parseInt($(this).width() * 0.08)},
						{field:'PSAM_NO2',title:'住建PSAM卡号',sortable:true,width : parseInt($(this).width() * 0.08)},
						{field:"USAGE",title:"终端用途",sortable:true,formatter:function(value,row){
			            	  if(row.USAGE == '1'){
			            		  return '1-支付终端';
			            	  }else if(row.USAGE == '2'){
			            		  return '2-非支付终端';
			            	  }else{
			            		  return '其他';
			            	  }
			              }},
						{field:"END_SRC",title:"终端来源",sortable:true,formatter:function(value,row){
			            	  if(row.END_SRC == '1'){
			            		  return '自购';
			            	  }else if(row.END_SRC == '2'){
			            		  return '租用';
			            	  }else{
			            		  return '其他';
			            	  }
			              }},
						
			        	{field:"MODEL",title:"终端型号",sortable:true},
			        	{field:"DEV_NO",title:"设备号",sortable:true},
			        	{field:"SIM_NO",title:"sim卡卡号",sortable:true},
			        	{field:"ACPT_TYPE",title:"所属类型",sortable:true,formatter:function(value,row){
			            	  if(row.ACPT_TYPE == '0'){
			            		  return '0-商户 ';
			            	  }else if(row.ACPT_TYPE == '1'){
			            		  return '1-网点';
			            	  }else{
			            		  return '其他';
			            	  }
			              }},

			        	{field:"LOGIN_TIME",title:"最近登陆时间",sortable:true},
			        	{field:"DEAL_BATCH_NO",title:"终端交易批次号",sortable:true},
			        	{field:"MNG_USER_ID",title:"管理人",sortable:true},
			        	{field:"PRODUCER",title:"生产厂家",sortable:true},
			        	{field:"CONTRACT_NO",title:"合同号",sortable:true},
			        	{field:"BUY_DATE",title:"采购日期",sortable:true},
			        	{field:"PRICE",title:"采购单价",sortable:true},
			        	{field:"MAINT_PERIOD",title:"保修截止日期",sortable:true},
			        	{field:"MAINT_CORP",title:"维护厂家",sortable:true},
			        	{field:"MAINT_PHONE",title:"维修厂家电话",sortable:true},
			         	{field:"REG_DATE",title:"启用日期",sortable:true},
			        	{field:"REG_USER_ID",title:"启用人",sortable:true},
			        	{field:"CLS_USER_ID",title:"注销人",sortable:true},
			        	{field:"CLS_DATE",title:"注销日期",sortable:true},
			        	{field:"RECYCLE_DATE",title:"回收日期",sortable:true},
			        	{field:"RECYCLE_TIME",title:"回收操作时间",sortable:true},
			        	{field:"RECYCLE_USER_ID",title:"回收人",sortable:true},
			        	{field:"NOTE",title:"备注",sortable:true}

			        ]]
			   });
				$.autoComplete({
					id:"merchantName",
					text:"merchant_name",
					value:"merchant_name",
					table:"base_merchant",
					where:"merchant_state = '0'",
					keyColumn:"merchant_id,merchant_name",
					minLength:1,
					reverse:true
				});
			});
		
		function query(){
			var c=getformdata("searchCont");
			$dg.datagrid('load',{
				"merchantId":$("#merchantName").combobox("getValue"),
				"endId":$("#endId").val(),
				"endName":$("#endName").val(),
				"endState":$("#endState").combobox("getValue")
			});
		}
		
		//弹窗修改
		function updRowsOpenDlg() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				$.modalDialog({
					title : "编辑终端信息",
					width : 870,
					height : 500,
					href : "/merchantRegister/merchantRegisterAction!toEditTerm.action?endId="+rows[0].END_ID,
					buttons : [ {
						text : '编辑',
						iconCls : 'icon-ok',
						handler : function() {
							$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = $.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							$.modalDialog.handler.dialog('destroy');
							$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}else{
				$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		//弹窗增加
		function addRowsOpenDlg() {
			var row = $dg.datagrid('getSelected');
			$.modalDialog({
				title : "新增终端信息",
				width : 870,
				height : 500,
				resizable:true,
				href : "/merchantRegister/merchantRegisterAction!toAddMerTerm.action?type=0",
				buttons : [ {
					text : '保存',
					iconCls : 'icon-ok',
					handler : function() {
						$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
						var f = $.modalDialog.handler.find("#form");
						f.submit();
					}
				}, {
					text : '取消',
					iconCls : 'icon-cancel',
					handler : function() {
						$.modalDialog.handler.dialog('destroy');
						$.modalDialog.handler = undefined;
					}
				}
				]
			});
		}
		
		function delRowsOpenDlg(){
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				$.ajax({
					url:"/merchantRegister/merchantRegisterAction!delTermInfo.action?endId="+rows[0].ID,
					success: function(rsp){
						rsp = eval('('+rsp+')');
						parent.$.messager.show({
							title : "系统消息",
							msg : "报废成功",
							timeout : 1000 * 2
						});
						query();
					}
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		//报修登记
		function updateTermRepairs() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				$.modalDialog({
					title : "报修登记",
					width : 870,
					height : 300,
					resizable:true,
					href : "/merchantRegister/merchantRegisterAction!toTermRepairs.action?endId="+rows[0].END_ID,
					buttons : [ {
						text : '报修登记',
						iconCls : 'icon-ok',
						handler : function() {
							$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = $.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							$.modalDialog.handler.dialog('destroy');
							$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}else{
				$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		
		//回收
		function recycle() {
			var rows = $dg.datagrid('getChecked');
			if (rows.length==1) {
				parent.$.modalDialog({
					title : "回收",
					width : 350,
					height : 180,
					resizable:true,
					href : "/merchantRegister/merchantRegisterAction!toRecycle.action?endId="+rows[0].END_ID,
					buttons : [ {
						text : '终端回收',
						iconCls : 'icon-ok',
						handler : function() {
							parent.$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = parent.$.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							parent.$.modalDialog.handler.dialog('destroy');
							parent.$.modalDialog.handler = undefined;
						}
					}
					]
				});
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择一行记录!",
					timeout : 1000 * 2
				});
			}
		}
		//终端出库房信息编辑
		function outboundAdd(){
			var rows = $dg.datagrid('getChecked');
			
			if(!rows || rows.length != 1){
				jAlert("请选择一条记录", "warnning");
				return;
			}
				$.modalDialog({
					title : "出库",
					width:740,
					height:300,
					resizable:true,
					maximizable:true,
					maximized:true,
					href : "merchantRegister/merchantRegisterAction!toOutbound.action?endId="+rows[0].END_ID,
					buttons : [ 
					{
						text : '出库撤销',
						iconCls : 'icon-ok',
						handler : function() {
							outCancle();
						}
					}, {
						text : '终端出库记录',
						iconCls : 'icon-ok',
						handler : function() {
							$.modalDialog.openner= $grid;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
							var f = $.modalDialog.handler.find("#form");
							f.submit();
						}
					}, {
						text : '取消',
						iconCls : 'icon-cancel',
						handler : function() {
							$.modalDialog.handler.dialog('destroy');
							$.modalDialog.handler = undefined;
						}
					}
					]
				});
		}
		
		/**
		 *启用或是禁用
	 	 */
		function enableOrDisable(type){
			var st = "";
			if(type == "1"){
				st = "启用商户终端";
			}else if(type == "9"){
				st = "注销商户终端";
			}
			var currow = $dg.datagrid("getSelections");
			if(!currow || currow.length == 0){
				jAlert("请选择终端信息", "warning");
				return;
			}
			
			var arr = [];
			for(var i in currow){
				arr.unshift(currow[i].END_ID);
			}
			
			$.messager.confirm("系统消息","您确定要【" + st + "】吗？",function(r){
				if(r){
					$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
					$.post("merchantRegister/merchantRegisterAction!saveDisableOrEnableMerTer.action","endId=" + arr.join(",") + "&queryType=" + type,function(data,status){
						$.messager.progress('close');
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"), function() {
							 if(data.status == "0"){
								 $dg.datagrid("reload");
							 }
						})
					},"json");
				}
			});
		}
		
		function openImprotDlg(){
			$("#div_import").dialog("open");
		}
		
		function importTmls(){
			var val = $("#importFile").val();
			if(!val){
				jAlert("请选择导入文件", "warning");
				return;
			}
			
			$.messager.confirm("系统消息", "确定导入选择的批量终端文件？", function(r){
				if(r){
					$.messager.progress({
						text:"数据处理中, 请稍候..."
					});
					$.ajaxFileUpload({  
			            url:"merchantRegister/merchantRegisterAction!importBatchTerminals.action",
			            fileElementId:['importFile'],
			            dataType:"json",
			            success: function(data, status){
			            	$.messager.progress("close");
			            	
			            	if(data.status == '1'){
			            		jAlert(data.errMsg, 'warning');
			            		return;
			            	}
			            	
			            	if(data.hasFail){
			            		$.messager.confirm("系统消息", data.msg + ", 点击【确定】导出失败记录", function(r){
			            			if(r){
			            				$("#div_import").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!exportBatchTerminalsFaliList.action?expid=" + data.expid);
			            			}
			            		});
			            	} else {
				            	$.messager.alert("系统消息", data.msg, "info", function(){
					            	$("#div_import").dialog("close");
				            	});
			            	}
			            },
			            error: function (data, status, e){
			            	$.messager.progress("close");
			            	jAlert(e, 'error');
			            }
			        });
				}
			});
		}
		
		function downloadTemplate(){
			$("#div_import").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=merchantEndBatchImportTemplate");
		}
	</script>
	
  </head>
  <body>
  <div class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户终端</strong></span>进行相应操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
			<form id="searchCont">
				<table cellpadding="0" cellspacing="0" class="tablegrid">
					<tr>
						<td class="tableleft">商户名称：</td>
						<td class="tableright"><input id="merchantName" type="text" class="textinput" name="merchantName"/></td>
						<td class="tableleft">终端编号：</td>
						<td class="tableright"><input id="endId" type="text" class="textinput" name="endId" /></td>
						<td class="tableleft">终端名称：</td>
						<td class="tableright"><input id="endName" type="text" class="textinput" name="endName" /></td>
						<td class="tableleft">终端状态</td >
						<td class="tableright">
							<select id="endState" class="easyui-combobox textinput" name="endState">
					    		<option value="">请选择</option>
								<option value="0">未启用</option>
								<option value="1">已启用</option>
								<option value="2">维修</option>
								<option value="3">报废</option>
								<option value="4">出库</option>
								<option value="5">回收</option>
								<option value="9">注销</option>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="8" style="padding-left: 25px;">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add"  plain="false" onclick="addRowsOpenDlg();">添加</a>				
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="updRowsOpenDlg();">变更</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-checkInfo"  plain="false" onclick="updateTermRepairs();">报修登记</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import"  plain="false" onclick="outboundAdd();">出库</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back"  plain="false" onclick="recycle();">回收</a>
							<a href="javascript:void(0);" class="easyui-menubutton" iconCls="icon-checkInfo" data-options="menu:'#mm1'" plain="false" onclick="javascript:void(0)">状态</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="openImprotDlg()">批量导入</a>
						</td>
					</tr>
				</table>
				</form>
			</div>
	  		<table id="dg" title="终端信息"></table>
	  		<div id="mm1" style="width:50px;display: none;">
	  		<div  data-options="iconCls:'icon-remove'"  onclick="delRowsOpenDlg();">报废</div>
	  		<div class="menu-sep"></div>
			<div data-options="iconCls:'icon-signout'" onclick="enableOrDisable('9');">注销</div>
			<div class="menu-sep"></div>
			<div data-options="iconCls:'icon-signin'" onclick="enableOrDisable('1');">激活</div>
		    </div>
	  </div>
		<div id="div_import" style="padding: 1% 10%" class="datagrid-toolbar">
			<table width="100%" style="margin-top: 5px">
				<tr>
					<td><input name="file" type="file" id="importFile" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel"></td>
					<td><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="importTmls()">导入</a></td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
		</div>
	</body>
</html>
