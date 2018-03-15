<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
	<script type="text/javascript">
		var customerId = <%=request.getParameter("customerId")%>;
		var $dgview;
		var $gridview;
		var $girdtest;
		var taskId="";
		var readCardFlag = true;
		$(function(){
			$("#div_import").dialog({
				title : "单位批量充值导入",
				width : 400,
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
					$("#excel").val("");
					$("#jugeCorp").attr("checked", true);
				}
			});
			
			$("#rcgState").combobox({
				valueField:"value",
				textField:"text",
				data:[
					{value:"", text:"请选择"},
					{value:"0", text:"待审核"},
					{value:"1", text:"部分审核"},
					{value:"2", text:"已审核"},
					{value:"3", text:"部分发放"},
					{value:"4", text:"已发放"},
					{value:"5", text:"已删除"}
				],
				editable:false,
				panelHeight: 'auto'
			});
			
			$dgview = $("#dgview");
			$gridview=$dgview.datagrid({
				url:"corpManager/corpManagerAction!queryImportBatchInfo.action",
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				fit:true,
				fitColumns:true,
				singleSelect:false,
				pageList:[20,50,100,200,500],
				singleSelect:true,
				frozenColumns:[[
					{field:'',checkbox:true},
					{field:'ID',title:'导入批次号',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'CUSTOMER_ID',title:'单位编号',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'RECHAGE_TYPE',title:'充值类型',sortable:true,width:parseInt($(this).width()*0.06), formatter:function(value){
						if(value == "00") {
							return "普通充值";
						} else {
							return "其他[" + value + "]";
						}
					}},
					{field:'NUM',title:'充值人数',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'AMT',title:'充值金额',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'STATE',title:'状态',sortable:true,width:parseInt($(this).width()*0.06), formatter : function(value){
						if(value == "0") {
							return "<span style='color:orange'>待审核</span>";
						} else if(value == "1") {
							return "<span style='color:orange'>部分审核</span>";
						} else if(value == "2") {
							return "<span style='color:green'>已审核</span>";
						} else if(value == "3") {
							return "<span style='color:blue'>部分发放</span>";
						} else if(value == "4") {
							return "<span style='color:blue'>已发放</span>";
						} else if(value == "5") {
							return "<span style='color:red'>已删除</span>";
						}
					}}
				]],
				columns:[[ 
					{field:'IMP_DEAL_DATE',title:'导入时间',sortable:true,minWidth:parseInt($(this).width()*0.2)},
					{field:'IMP_UERS_ID',title:'导入柜员',sortable:true,minWidth:parseInt($(this).width()*0.08)},
					{field:'CHECK_DEAL_DATE',title:'审核时间',sortable:true,minWidth:parseInt($(this).width()*0.2)},
					{field:'CHECK_USER_ID',title:'审核柜员',sortable:true,minWidth:parseInt($(this).width()*0.08)},
					{field:'RECHAGE_DEAL_DATE',title:'充值时间',sortable:true,minWidth:parseInt($(this).width()*0.2)},
					{field:'RECHAGE_USER_ID',title:'充值柜员',sortable:true,minWidth:parseInt($(this).width()*0.08)},
					{field:'NOTE',title:'备注',sortable:true,minWidth:parseInt($(this).width()*0.5)}
				]],
				toolbar:'#tbview',
				onLoadSuccess:function(data){
		            	if(data.status != 0){
		            		$.messager.alert('系统消息',data.errMsg,'warning');
		            	}
	            	},
	            queryParams:{
	            	customerId:customerId
	            }
			});
		});
		
		function importFromExcel(){
			$.messager.progress({text:"数据处理中，请稍候..."});
			$.ajaxFileUpload({  
                url:"corpManager/corpManagerAction!importCorpBatchRechargeInfo.action?customerId=" + customerId + "&jugeCorp=" + $("#jugeCorp:checked").val(),
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
        						msg += "<br>[姓名:" + array[i].name + ", 证件号码:" + array[i].certNo + ", " + array[i].note + "]";
        					}
        				}
            			
            			$.messager.alert("消息提示",msg,"info", function(){
            				$("#div_import").dialog("close");
	            			$dgview.datagrid('reload');
            			});
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
		
		function queryCorpBatchRechargeInfo(){
			$dgview.datagrid("load", {
				customerId:customerId,
				"info.id":$("#rcgInfoId").val(),
				"info.impDealDate":$("#importDate").val(),
				"info.state":$("#rcgState").combobox('getValue')
			});
		}
		
		function batchDetail() {
			var rows = $dgview.datagrid('getSelections');
			
			if(rows.length != 1) {
				$.messager.alert('系统消息','请选择一条记录','warning');
				return;
			}
			
			var title = "单位批量充值明细";
			var url = "/jsp/corp/importCorpBatchRechargeInfoDetail.jsp?customerId=" + rows[0].CUSTOMER_ID + "&rcgInfoId=" + rows[0].ID;
			
			modalWindow(title, url);
		}
		
		function openImprotDlg(){
			$("#div_import").dialog("open");
		}
		
		function downloadTemplate(){
			$("#div_import").children("iframe").attr("src", "merchantRegister/merchantRegisterAction!downloadTemplate.action?template=corpBatchRechargeTemplate");
		}
		
		function deleteBatch(){
			var rows = $dgview.datagrid('getSelections');
			
			if(rows.length != 1) {
				$.messager.alert('系统消息','请选择一条记录','warning');
				return;
			} else if(rows[0].STATE != 0){
				$.messager.alert('系统消息','批量充值数据不是【待审核】状态，不能删除','warning');
				return;
			}
			
			$.messager.confirm("系统消息", "确认删除序列号为 【" + rows[0].ID + "】 的批量充值数据", function(r){
				if(r){
					$.messager.progress({text:"数据处理中, 请稍候..."});
					$.post("corpManager/corpManagerAction!deleteBatchInfo.action", {"info.id":rows[0].ID}, function(data){
						$.messager.progress("close");
						if(data.status == 0){
							jAlert("操作成功", "info", function(){
								$dgview.datagrid('load');
							});
						} else {
							jAlert(data.errMsg, "warning");
						}
					}, "json");
				}
			});
		}
	</script>
  <div class="easyui-layout" data-options="fit:true">
	  <div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		  <div id="tbview" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" width="100%">
					<tr>
						<td style="padding:0 3px;" class="tableleft">序列号：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" id="rcgInfoId" class="textinput"/></td>
						<td style="padding:0 3px;" class="tableleft">导入时间：</td>
						<td style="padding:0 3px;" class="tableright">
							<input id="importDate" class="textinput Wdate" editable="false" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						</td>
						<td style="padding:0 3px;" class="tableleft">状态：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" id="rcgState" class="textinput"/></td>
						<td style="padding:0 3px;" class="tableright">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton2" name="subbutton" onclick="queryCorpBatchRechargeInfo()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-import'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton3" name="subbutton" onclick="openImprotDlg()">导入</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-remove'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton3" name="subbutton" onclick="deleteBatch()">删除</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-viewInfo'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton4" name="subbutton" onclick="batchDetail()">明细</a>
						</td>
					</tr>
				</table>
			</div>
		    <table id="dgview"></table>
	  </div>
	  <div id="div_import" style="padding: 5% 10% 0 10%;" class="datagrid-toolbar">
	      <table width="100%">
			  <tr>
				  <td>
				  	   <input id="excel" name="file" type="file" style="border: 1px #ccc solid;" accept="application/vnd.ms-excel">
				  	  <button onclick="importFromExcel()">导入</button>
				  </td>
			  </tr>
			  <tr>
			  	 <td colspan="2" style="padding-top: 2px">
				  	   <input id="jugeCorp" type="checkbox" name="jugeCorp" value="true" checked="checked"/>验证单位 
				  </td>
			  </tr>
		  </table>
		  <br>
		  <a href="javascript:void(0)" onclick="downloadTemplate()">点击此处</a>下载导入模版
		  <iframe style="display: none;"></iframe>
	  </div>
  </div>
