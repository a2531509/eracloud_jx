<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>个人信息管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		$(function(){
			$(document).keypress(function(event){
				if(event.keyCode == 13){
					basePersonalinfoquery();
				}
			});
			
		$("#div_import").dialog({
				title : "人员导入",
				width : 450,
				height : 200,
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
			
			createSysCode({
				id:"certType",codeType:"CERT_TYPE",value:"<%=Constants.CERT_TYPE_SFZ%>"
			});
			createLocalDataSelect({
				id:"isPhoto",
			    data:[{value:'',text:"请选择"},{value:'0',text:"是"},{value:'1',text:"否"}]
			});
			createLocalDataSelect({
				id:"sureFlag2",
			    data:[{value:'',text:"请选择"},{value:'0',text:"是"},{value:'1',text:"否"}]
			});
			createLocalDataSelect({
				id:"customerState2",
			    data:[{value:'',text:"请选择"},{value:'0',text:"正常"},{value:'1',text:"注销"}]
			});
			//$.addIdCardReg("certNo");
			$.autoComplete({
				id:"certNo",
				text:"cert_no",
				value:"name",
				table:"base_personal",
				keyColumn:"cert_no",
				optimize:true
				//minLength:"1"
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
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"dataAcount/dataAcountAction!findAllBasePersonal.action",
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				fit:true,
				singleSelect:true,
				pageSize:20,
				frozenColumns:[[
					{field:'V_V',checkbox:true},
					{field:'CUSTOMER_ID',title:'客户编号',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'NAME',title:'姓名',align:'center',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'CERTTYPE',title:'证件类型',align:'center',sortable:true,width:parseInt($(this).width()*0.05)},
					{field:'CERT_NO',title:'证件号码',align:'center',sortable:true,width:parseInt($(this).width()*0.12)},
					{field:'MOBILE_NO',title:'手机号码',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'REGION_NAME',title:'区域',align:'center',sortable:true,width:parseInt($(this).width()*0.05)}
				]],
				columns:[[
					{field:'TOWN_NAME',title:'乡镇（街道）',align:'center',sortable:true,width:parseInt($(this).width()*0.11)},
					{field:'COMM_NAME',title:'社区（村）',align:'center',sortable:true,width:parseInt($(this).width()*0.15)},
					{field:'CORP_CUSTOMER_ID',title:'单位编号',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'CORP_NAME',title:'单位名称',align:'center',sortable:true,width:parseInt($(this).width()*0.15)},
					{field:'SURE_FLAG',title:'确认标志',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'RESIDETYPE',title:'户籍类型',align:'center',sortable:true,width:parseInt($(this).width()*0.05)},
					{field:'BIRTHDAY',title:'出生日期',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'GENDERS',title:'性别',align:'center',sortable:true,width:parseInt($(this).width()*0.03)},
					{field:'NATION',title:'民族',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'PINYING',title:'姓名拼音',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'RESIDE_ADDR',title:'居住地址',align:'center',sortable:true,width:parseInt($(this).width()*0.15)},
					{field:'LETTER_ADDR',title:'联系地址',align:'center',sortable:true,width:parseInt($(this).width()*0.15)},
					{field:'EMAIL',title:'电子邮件',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'PHONE_NO',title:'固定电话1',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'TEL_NOS',title:'固定电话2',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'MOBILE_NOS',title:'手机号码2',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'EDUCATION',title:'文化程度',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'MARR_STATE',title:'婚姻状态',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'CAREER',title:'职业',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'CUSTOMER_STATE',title:'客户状态',align:'center',sortable:true,width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
							if(value == "正常"){return value;}else{return '<div style="color:red;width:100%;height:100%;border:1px solid red;">' + value + '</div>';}
						},styler:function(value,row,index){
							if(value == "正常"){return "";}else{return 'padding:0px;margin:0px;';}
						}
					},
					{field:'DATA_SRC',title:'数据来源',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'NOTE',title:'备注',sortable:true,width:parseInt($(this).width()*0.50)}
				]],toolbar:'#tb',
				onLoadSuccess:function(data){
	            	$("input[type=checkbox]").each(function(){
	        			this.checked = false;
	        		});
	            	if(data.status != 0){
	            	    $.messager.alert('系统消息',data.errMsg,'error');
	            	}else{
	            		if(data.rows.length == 1){
	            			$grid.datagrid("selectRow",0);
	            		}
	            	}
	            },
	            onRowContextMenu:function(e,index,rowdata){
	            	e.preventDefault(); 
	            	addOrEditBasePersonal('1');
	            	return false;
	            },onBeforeLoad:function(param){
	            	if(dealNull(param["queryType"]) != ""){
	            		if(/^[\u4e00-\u9fa5]+$/.test($("#regionId2").combobox("getValue"))){
	            			$.messager.alert("系统消息","所属区域选择不正确！","error");
	            			return false;
	            		}
	            		if(/^[\u4e00-\u9fa5]+$/.test($("#townId2").combobox("getValue"))){
	            			$.messager.alert("系统消息","所属乡镇（街道）选择不正确！","error");
	            			return false;
	            		}
	            		if(/^[\u4e00-\u9fa5]+$/.test($("#commId2").combobox("getValue"))){
	            			$.messager.alert("系统消息","所属社区（村）选择不正确！","error");
	            			return false;
	            		}
	            	}
	            }
			});
			createRegionSelect({id:"regionId2"},{id:"townId2"},{id:"commId2"});
		});
		
		
			/* 	function tofileUploadPerson(){
				$.modalDialog({
				title: "人员数据导入",
				width:800,
				height:250,
				resizable:false,
				href:"jsp/dataAcount/importPersonView.jsp",
				onLoad: function() {
					var f = $.modalDialog.handler.find("#form");
					f.form("load", {
						"bp.certNo":$("#certNo").val()
					});
				},
				buttons:[{
					text:"保存",
					iconCls:"icon-ok",
					handler:function() {
						fileUploadPerson();
					}
				},{
					text:"取消",
					iconCls:"icon-cancel",
					handler:function() {
						$.modalDialog.handler.dialog("destroy");
					    $.modalDialog.handler = undefined;
					}
				}]
			});
		 } */
		 	function openImprot(){
				$("#div_import").dialog("open");
			}
		 
		 	function importPerson(){
				var val = $("#importFile").val();
				if(!val){
					jAlert("请选择导入文件", "warning");
					return;
			}
			
			$.messager.confirm("系统消息", "确定导入选择的人员文件？", function(r){
				if(r){
					$.messager.progress({
						text:"数据处理中, 请稍候..."
					});
					$.ajaxFileUpload({  
			            url:"dataAcount/dataAcountAction!importPerson.action",
			            fileElementId:['importFile'],
			            dataType:"json",
			            
			            success: function(data, status){
			            	$.messager.progress("close");
			            	var msg = "";
			            	var hasFailItem = false;
			            	if(data.status == '1'){
			            		jAlert(data.errMsg, 'warning');
			            		return;
			            	}
		            		if(data.failList && data.failList.length > 0){
		            			hasFailItem = true;
		    					var array = data.failList;
		    					for(var i in array){
		    						msg += "姓名:<span style='color:red'>" + array[i].name + "</span>, 证件号码:<span style='color:red'>" + array[i].certNo + "</span>, 失败原因: <span style='color:red'>" + array[i].failMsg + "</span><br>";
   								}
		            		}
		            	
			            	
			            	if(data.hasFail){
			            		$.messager.confirm("系统消息", data.msg + "， 有失败的数据, 点击确定查看", function(r){
			            		if(r){
			            			$("#personwin").html(msg);
	        						$("#personwin").window({
	        							title:"失败数据",
	        							width:600,    
	        						    height:400,    
	        						    modal:true,
	        						    collapsible:false,
	        						    minimizable:false,
	        						    maximizable:false,
	        						    onClose:function(){
	        						    	$("#div_import").dialog("close");
	        						    }
	        						});
	        						$("#personwin").show();
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
			$("#div_import").children("iframe").attr("src", "/dataAcount/dataAcountAction!downloadTemplate.action?template=personTemplate");
		}
		
		function basePersonalinfoquery(){
			if($("#certNo").val() == "" && $("#corpCustomerId").val() == "" && $("#customerMobileNo").val() == "" && $("#name").val() == "" && $("#corpName").val() == ""
					&& ($("#regionId2").combobox("getValue") == "" || $("#townId2").combobox("getValue") == "")
		    ){
				$.messager.alert("系统消息","请输入查询条件！<div style=\"color:red\">提示：证件号码，姓名或单位编号、单位名称 或 区域、乡镇（街道）</div>","warning");
				return;
			}
			$dg.datagrid("load",{
				queryType:"0",
				"bp.certType":$("#certType").combobox("getValue"),
				"bp.certNo":$("#certNo").val(),
				"bp.name":$("#name").val(),
				"bp.corpCustomerId":$("#corpCustomerId").val(),
				"regionId":$("#regionId2").combobox("getValue"),
				"townId":$("#townId2").combobox("getValue"),
				"commId":$("#commId2").combobox("getValue"),
				"bp.customerState":$("#customerState2").combobox("getValue"),
				"corpName":$("#corpName").val(),
				"isPhoto":$("#isPhoto").combobox("getValue"),
				"bp.mobileNo":$("#customerMobileNo").val()
			});
		}
		//新增或是编辑
		function addOrEditBasePersonal(type) {
			var row = $dg.datagrid('getSelected');
			if(type == '0' || (row && type == '1')){
				var titlestring = "",titleicon = "",certNo = "";
				if(type == "0"){
					titlestring = "人员基本信息新增";
					titleicon = "icon-add";
				}else if(type == '1'){
					titlestring = "人员基本信息编辑";
					titleicon = "icon-edit";
					certNo = row.CUSTOMER_ID;
				}else{
					$.messager.alert("系统消息","操作类型传入错误！","error");
					return;
				}
				$.modalDialog({
					title:titlestring,
					iconCls:titleicon,
					fit:true,
					maximized:true,
					shadow:false,
					//inline:true,
					closable:false,
					maximizable:false,
					href:"dataAcount/dataAcountAction!toAddOrUpdateBasePersonal.action?queryType=" + type + "&bp.customerId=" + certNo ,
					buttons:[{
							text:'保存',
							iconCls:'icon-ok',
							handler:function(){
								saveAddOrUpdateBasePersonal();
							}
						},{
							text:'取消',
							iconCls:'icon-cancel',
							handler:function() {
								$.modalDialog.handler.dialog('destroy');
							    $.modalDialog.handler = undefined;
							}
						}
				   ]
				});
			}else{
				$.messager.alert("系统消息","请选择一条记录信息进行编辑！","error");
			}
		}
		function autoCom(){
			if($("#corpCustomerId").val() == ""){
				$("#corpName").val("");
				//return;
			}
			$("#corpCustomerId").autocomplete({
				position: {my:"left top",at:"left bottom",of:"#corpCustomerId"},
			    source: function(request,response){
				    $.post('dataAcount/dataAcountAction!toSearchInput.action',{"corpName":$("#corpCustomerId").val()},function(data){
				    	response($.map(data,function(item){return {label:item.text,value:item.value};}));
				    });
			    },
			    select: function(event,ui){
			      	$('#corpCustomerId').val(ui.item.label);
			        $('#corpName').val(ui.item.value);
			        return false;
			    },
		      	focus:function(event,ui){
			      	//$('#corpCustomerId').val(ui.item.label);
			        //$('#corpName').val(ui.item.value);
			        return false;
		      	}
		    }); 
		}
		function autoComByName(){
			if($("#corpName").val() == ""){
				$('#corpCustomerId').val("");
				//return;
			}
			$("#corpName").autocomplete({
		    source:function(request,response){
		        $.post('dataAcount/dataAcountAction!toSearchInput.action',{"corpName":$("#corpName").val(),"queryType":"0"},function(data){
		            response($.map(data,function(item){return {label:item.value,value:item.text};}));
		        });
		    },
		    select: function(event,ui){
		      	$('#corpCustomerId').val(ui.item.value);
		        $('#corpName').val(ui.item.label);
		        return false;
		    },
		    focus: function(event,ui){
		    	//$('#corpCustomerId').val(ui.item.value);
			    //$('#corpName').val(ui.item.label);
		        return false;
		    }
		    }); 
		}
		$(document).keydown(function (event){ 
			if(event.keyCode == 112){
				basePersonalinfoquery();
				event.preventDefault(); 
			}else if(event.keyCode == 115){
				addOrEditBasePersonal("1");
				event.preventDefault(); 
			}else{
				return true;
			}
		});
		//导出人员数据
			function exportDetail() {
			var selectId = "";
			var selections = $("#dg").datagrid("getSelections");
			if(selections && selections.length > 0){
				for(var i in selections){
					selectId += "|" + selections[i].CUSTOMER_ID;
				}
			}
		
			var params = getformdata("personForm");
			params["rows"] = 65530;
			params["bp.name"] = $("#name").val();
			if(selectId){
				params["selectedId"] = selectId.substring(1);
			}
		
			var paramsStr = "";
			for(var i in params){
				paramsStr += "&" + i + "=" + params[i];
			}
			$.messager.progress({text:"正在进行导出"});
			$('#download_iframe').attr('src',"dataAcount/dataAcountAction!exportPersonInfo.action?" + paramsStr.substring(1));
			startCycle();
		}
	
			function startCycle(){
				isExt = setInterval("startDetect()",800);
			}
			function startDetect(){
			commonDwr.isDownloadComplete("exportPersonInfo",function(data){
				if(data["returnValue"] == '0'){
					clearInterval(isExt);
					jAlert("导出成功","info",function(){
						$.messager.progress("close");
					});
				}
			});
		}
		
		/* function certNoPress(){
			var certType = $("#certType").combobox("getText");
			
			if(certType.trim() == "身份证"){
				basePersonalinfoquery();
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
			basePersonalinfoquery();
		} */
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>人员基础信息进行新增/编辑管理！<span style="color:red;">注意：</span>人员信息（村镇、社区）不完整可能会影响全功能卡的申领！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<form id="personForm">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width:8%">证件类型：</td>
					<td class="tableright" style="width:17%"><input type="text" name="bp.certType" id="certType" class="textinput"/></td>
					<td class="tableleft" style="width:8%">证件号码：</td>
					<td class="tableright" style="width:17%"><input type="text" name="bp.certNo" id="certNo" class="textinput" maxlength="18"/></td>
					<td class="tableleft" style="width:8%">姓名：</td>
					<td class="tableright" style="width:17%"><input type="text" name="bp.name" id="name" class="textinput" maxlength="10"/></td>
					<td class="tableleft">手机号码：</td>
					<td class="tableright"><input type="text" name="bp.mobileNo" id="customerMobileNo" class="textinput"/></td>
				</tr>
				<tr>
					<td class="tableleft">单位编号：</td>
					<td class="tableright"><input type="text" name="bp.corpCustomerId" id="corpCustomerId" maxlength="15" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
					<td class="tableleft">单位名称：</td>
					<td class="tableright"><input type="text" name="corpName" id="corpName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()" maxlength="50"/></td>
					<td class="tableleft">客户状态：</td>
					<td class="tableright"><input type="text" name="bp.customerState" id="customerState2" class="textinput"/></td>
					<td class="tableleft" style="width:8%">是否有照片：</td>
					<td class="tableright" style="width:17%"><input type="text" name="isPhoto" id="isPhoto" class="textinput"/></td>
					<!-- <td class="tableleft">是否确认：</td>
					<td class="tableright"><input type="text" name="bp.sureFlag" id="sureFlag2" class="textinput"/></td> -->
				</tr>
				<tr>
					<td class="tableleft">所属区域：</td>
					<td class="tableright"><input name="regionId" class="textinput" id="regionId2" type="text"/></td>
					<td class="tableleft">乡镇（街道）：</td>
					<td class="tableright"><input name="townId" class="textinput" id="townId2" type="text"/></td>
					<td class="tableleft">社区（村）：</td>
					<td class="tableright"><input name="commId" class="textinput" id="commId2" type="text"/></td>
					<td style="text-align:center;" colspan="2">
						<!-- <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a> -->
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="openImprot();">导入人员</a>						
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="basePersonalinfoquery();">查询</a>
						<shiro:hasPermission name="personAdd">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false" onclick="addOrEditBasePersonal('0');">添加</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="personEdit">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="addOrEditBasePersonal('1')">编辑</a>
						</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="人员基本信息"></table>
  		<iframe id="download_iframe" style="display: none;"></iframe>
  		</div>
  		 <div id="div_import" style="padding: 1% 10%" class="datagrid-toolbar">
			<table width="100%" style="margin-top: 5px">
				<tr>
					<td><input name="file" type="file" id="importFile" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel"></td>
					<td><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="importPerson()">导入</a></td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
		</div>
		<div id="personwin"></div>
</body>
</html>
