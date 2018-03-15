<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	$(function() {
		$("#state").combobox({
			textField:"text",
			valueField:"value",
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"已购买未生效"},
				{value:"1", text:"已购买已生效"}
			],
			panelHeight:"auto",
			editable:false
		});
		
		$("#source").combobox({
			textField:"text",
			valueField:"value",
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"微信购买"},
				{value:"1", text:"其它渠道"}
			],
			panelHeight:"auto",
			editable:false
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

		$("#dg").datagrid({
			url:"zxcApp/ZxcAppAction!queryCardInsurance.action",
			fitColumns:true,
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			toolbar:"#tb",
			pageList:[50, 100, 200, 500, 1000],
			frozenColumns:[[
				{field:"DEAL_NO", checkbox:true},
				{field:"CUSTOMER_ID",title:"客户编号",hidden:true, sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.13)},
				{field:"CARD_NO",title:"卡号",sortable:true,hidden:true,width:parseInt($(this).width()*0.14)},
				{field:"SUB_CARD_NO",title:"市民卡号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"MOBILE_NO",title:"电话号码",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,hidden:true,width:parseInt($(this).width()*0.06), formatter:function(value){
					if(value == "<%=Constants.CARD_TYPE_QGN%>"){
						return "全功能卡";
					} else if(value == "<%=Constants.CARD_TYPE_SMZK%>") {
						return "金融市民卡";
					} else {
						return value;
					}
				}},
			]],
			columns:[[
				{field:"INSURANCE_NO",title:"保单编号",sortable:true},
				{field:"INSURANCE_KIND",title:"保险种类",sortable:true},
				{field:"INSURED_DATE",title:"参保 / 购买日期",sortable:true},
				{field:"START_DATE",title:"有效期起始",sortable:true},
				{field:"END_DATE",title:"有效期截止",sortable:true},
				{field:"STATE",title:"状态",sortable:true, formatter:function(value){
					if(value == "0"){
						return "已购买未生效";
					} else if(value == "1") {
						return "已购买已生效";
					} else {
						return value;
					}
				}},
				{field:"ORDER_NO",title:"商户订单号",sortable:true},
				{field:"SOURCE",title:"来源",sortable:true, formatter:function(v){
					if(v == "0"){
						return "微信购买";
					} else {
						return "其它渠道【" + v + "】";
					}
				}},
				{field:"NOTE",title:"备注",sortable:true}
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
		params.name = $("#name").val();
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
	
	function importData(){
		$("#import_dialog").dialog("open");
	}
	
	function downloadTemplate(){
		$("#import_dialog").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=cardSuranceTemplate");
	}
	
	function importFromExcel(){
		$.messager.progress({text:"数据处理中，请稍候..."});
		$.ajaxFileUpload({  
            url:"zxcApp/ZxcAppAction!importCardInsurance.action",
            secureuri:false,  
            fileElementId:['excel'],
            dataType:"json",
            success: function(data, status){
            	$.messager.progress("close");
            	if(data.status == '0'){
            		var msg = "导入完成.";
        			
        			if(data.failList){
        				msg += "<br>" + data.msg + "<br>";
    					
    					var array = eval(data.failList);
    					
    					for(var i = 0; i< array.length; i++){
    						msg += "<br>[" + array[i].note + "]";
    					}
    				}
        			
        			$.messager.alert("消息提示",msg,"info", function(){
        				$("#import_dialog").dialog("close");
            			$("#dg").datagrid('reload');
        			});
            	}else{
            		$.messager.alert('消息提示',data.errMsg,'error');
            	}
            },
            error: function (data, status, e){
            	$.messager.alert("消息提示", "网络连接异常, " + status, "error");
            	$("#dg").datagrid('load');
            }
        });
	}
	
	function deleteItem(){
		var selection = $("#dg").datagrid("getSelected");
		if(!selection){
			jAlert("请选择一条记录", "warning");
			return;
		}
		
		$.messager.confirm("", "确认删除所选条目？", function(r){
			if(r){
				$.post("zxcApp/ZxcAppAction!deleteCardInsurance.action", {dealNo:selection.DEAL_NO}, function(data){
					if(data.status == 1){
						jAlert(data.errMsg, "error");
					} else {
						jAlert("删除成功！", "info", function(){
							query();
						});
					}
				}, "json");
			}
		});
	}
	
	function exportData(){
		var selection = $("#dg").datagrid("getSelections");
		var paramStr = "";
		if(selection && selection.length > 0){
			for(var i in selection){
				paramStr += selection[i].CARD_NO + selection[i].INSURANCE_NO + ",";
			}
			if(paramStr){
				paramStr = paramStr.substring(0, paramStr.length - 1);
			}
		}
		//
		var paramString = "";
		var params = getformdata("searchConts");
		params.name = $("#name").val();
		if(params && params.length > 0){
			for(var i in params){
				paramString += "&" + i + "=" + params[i];
			}
		}
		if(paramStr){
			paramString += "&selectId=" + paramStr;
		}
		if(paramString){
			paramString = paramString.substring(1);
		}
		$("#import_dialog").children("iframe").attr("src", "zxcApp/ZxcAppAction!exportCardInsurance.action?" + paramString);
	}
</script>
<n:initpage title="卡片参保信息进行查询，以及导入参保数据！">
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
					</tr>
					<tr>
						<td class="tableleft">保单编号：</td>
						<td class="tableright">
							<input id="insuranceNo" type="text" class="textinput" name="insuranceNo"/>
						</td>
						<td class="tableleft">参保状态：</td>
						<td class="tableright"><input  id="state" type="text" name="state" class="textinput"/></td>
						<td class="tableleft">购买渠道：</td>
						<td class="tableright"><input  id="source" type="text" name="source" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">参保 / 购买日期：</td>
						<td class="tableright" colspan="3">
							<input  id="beginTime" type="text" name="startDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
							&nbsp;&nbsp;——&nbsp;&nbsp;
							<input id="endTime" type="text"  name="endDate" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
						<td class="tableright" colspan="2" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="insuranceDelete">
								&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-remove'" href="javascript:void(0);" class="easyui-linkbutton" onclick="deleteItem()">删除</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="insuranceImport">
								&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-import'" href="javascript:void(0);" class="easyui-linkbutton" onclick="importData()">导入</a>
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-export'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportData()">导出</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="卡片参保信息"></table>
  		<div id="import_dialog" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	  		<table width="100%">
				<tr>
					<td>
						<input id="excel" name="file" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
						<button onclick="importFromExcel()">导入</button>
					</td>
				</tr>
			</table>
			<br>
			<a href="javascript:void(0)" onclick="downloadTemplate()">点击此处</a>下载导入模版
			<iframe style="display: none;"></iframe>
  		</div>
  	</n:center>
</n:initpage>