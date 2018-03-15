<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
	<script type="text/javascript">
		var customerId = <%=request.getParameter("customerId")%>;
		var rcgInfoId = <%=request.getParameter("rcgInfoId")%>;
		var $dgview2;
		var $gridview2;
		$(function(){
			$("#rcgState2").combobox({
				valueField:"value",
				textField:"text",
				data:[
					{value:"", text:"请选择"},
					{value:"0", text:"待审核"},
					{value:"1", text:"已审核"},
					{value:"3", text:"已发放"},
					{value:"4", text:"已删除"}
				],
				editable:false,
				panelHeight: 'auto'
			});
			
			$dgview2 = $("#dgview2");
			$gridview2=$dgview2.datagrid({
				url:"corpManager/corpManagerAction!queryImportCorpBatchRechargeInfo.action",
				pagination:true,
				rownumbers:true,
				border:true,
				striped:true,
				fit:true,
				fitColumns:true,
				singleSelect:false,
				pageList:[100, 200, 500, 1000, 2000],
				frozenColumns:[[
					{field:'ID',checkbox:true},
					{field:'RCG_INFO_ID',title:'导入批次号',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'CUSTOMER_ID',title:'人员编号',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'NAME',title:'人员姓名',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'AMT',title:'充值金额',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'STATE',title:'状态',sortable:true,width:parseInt($(this).width()*0.05), formatter : function(value){
						if(value == "0") {
							return "<span style='color:orange'>待审核</span>";
						} else if(value == "1") {
							return "<span style='color:green'>已审核</span>";
						} else if(value == "3") {
							return "<span style='color:blue'>已发放</span>";
						} else if(value == "4") {
							return "<span style='color:red'>已删除</span>";
						}
					}}
				]],
				columns:[[ 
					{field:'CERT_NO',title:'证件号码',sortable:true,minWidth:parseInt($(this).width()*0.12)},
					{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width()*0.14)},
					{field:'ACC_KIND',title:'账户类型',sortable:true,minWidth:parseInt($(this).width()*0.05)},
					{field:'IMP_DEAL_DATE',title:'导入时间',sortable:true,minWidth:parseInt($(this).width()*0.2)},
					{field:'IMP_UERS_ID',title:'导入柜员',sortable:true,minWidth:parseInt($(this).width()*0.08)},
					{field:'CHECK_DEAL_DATE',title:'审核时间',sortable:true,minWidth:parseInt($(this).width()*0.2)},
					{field:'CHECK_USER_ID',title:'审核柜员',sortable:true,minWidth:parseInt($(this).width()*0.08)},
					{field:'RECHAGE_DEAL_DATE',title:'充值时间',sortable:true,minWidth:parseInt($(this).width()*0.2)},
					{field:'RECHAGE_USER_ID',title:'充值柜员',sortable:true,minWidth:parseInt($(this).width()*0.08)},
					{field:'NOTE',title:'备注',sortable:true,minWidth:parseInt($(this).width()*0.5)}
				]],
				toolbar:'#tbview2',
				onLoadSuccess:function(data){
		            	  if(data.status != 0){
		            		 $.messager.alert('系统消息',data.errMsg,'error');
		            	  }
	            	},
	            queryParams:{
	            	customerId:customerId,
	            	"list.pk.rcgInfoId":rcgInfoId
	            }
			});
		});
		
		function deleteData(){
			var rows = $dgview2.datagrid('getSelections');
			var dataSeqs="";
			if(rows.length > 0){
				//组转勾选的参数
				for(var i=0;i<rows.length;i++){
					if(rows[i].STATE != 0){
						jAlert(rows[i].NAME + ", " + rows[i].CERT_NO + " 不是【待审核】状态", "warning");
						return;
					}
					dataSeqs = dataSeqs + rows[i].RCG_INFO_ID + "|" + rows[i].CUSTOMER_ID + ",";
				}
				$.messager.confirm('系统消息','你确定删除' + rows.length + '条批量充值记录吗？', function(r){
		     		if (r){
		     			$.messager.progress({text:"数据处理中，请稍候..."});
		     			$.post("corpManager/corpManagerAction!deleteCorpBatchRechargeInfo.action", {selections:dataSeqs,customerId:customerId},
		     				function(data){
		     				$.messager.progress("close");
		     				if(data.status == '0'){
		                		var msg = "删除完成.";
		            			
		            			if(data.failList){
		            				msg += "<br>" + data.msg + "<br>";
		        					
		        					var array = eval(data.failList);
		        					
		        					for(var i = 0; i< array.length; i++){
		        						msg += "<br>[序列号:" + array[i].pk.rcgInfoId + ", 人员编号:" + array[i].pk.customerId + ", " + array[i].note + "]";
		        					}
		        				}
		            			
		            			$.messager.alert("消息提示",msg,"info");
		            			
		            			$dgview2.datagrid('load');
		                	}else{
		                		$.messager.alert('消息提示',data.errMsg,'error');
		                	}
		     			}, "json");
		     		}
		     	});
			}else{
				$.messager.alert('系统消息','请选择操作记录','info');
			}
		}
		
		function rechargeFromCorpBatchRechargeInfo(){
			var rows = $dgview2.datagrid('getSelections');
			var dataSeqs="";
			if(rows.length > 0){
				//组转勾选的参数
				for(var i=0;i<rows.length;i++){
					if(rows[i].STATE != 1){
						jAlert(rows[i].NAME + ", " + rows[i].CERT_NO + " 不是【已审核】状态", "warning");
						return;
					}
					dataSeqs = dataSeqs + rows[i].RCG_INFO_ID + "|" + rows[i].CUSTOMER_ID + ",";
				}
				$.messager.confirm('系统消息','你确定将' + rows.length + '条记录充值到全功能卡联机账户吗？', function(r){
		     		if (r){
		     			$.messager.progress({text:"数据处理中，请稍候..."});
		     			$.post("corpManager/corpManagerAction!rechargeFromCorpBatchRechargeInfo.action", {selections:dataSeqs,customerId:customerId},
		     				function(data){
		     				$.messager.progress("close");
		     				if(data.status == '0'){
		                		var msg = "充值完成.";
		            			
		            			if(data.failList){
		            				msg += "<br>" + data.msg + "<br>";
		        					
		        					var array = eval(data.failList);
		        					
		        					for(var i = 0; i< array.length; i++){
		        						msg += "<br>[序列号:" + array[i].pk.rcgInfoId + ", 人员编号:" + array[i].pk.customerId + ", " + array[i].note + "]";
		        					}
		        				}
		            			
		            			$.messager.alert("消息提示",msg,"info");
		            			
		            			$dgview2.datagrid('load');
		                	}else{
		                		$.messager.alert('消息提示',data.errMsg,'error');
		                	}
		     			}, "json");
		     		}
		     	});
			}else{
				$.messager.alert('系统消息','请选择操作记录','info');
			}
		}
		
		function queryCorpBatchRechargeInfoDetail(){
			$dgview2.datagrid("load", {
				customerId:customerId,
				"list.pk.rcgInfoId":rcgInfoId,
				"list.certNo":$("#rcgCertNo").val(),
				"list.state":$("#rcgState2").combobox('getValue')
			});
		}
		
		function checkPass() {
			var rows = $dgview2.datagrid('getSelections');
			var dataSeqs="";
			if(rows.length > 0){
				//组转勾选的参数
				for(var i=0;i<rows.length;i++){
					if(rows[i].STATE != 0){
						jAlert(rows[i].NAME + ", " + rows[i].CERT_NO + " 不是【待审核】状态", "warning");
						return;
					}
					dataSeqs = dataSeqs + rows[i].RCG_INFO_ID + "|" + rows[i].CUSTOMER_ID + ",";
				}
				$.messager.confirm('系统消息','你确定审核通过' + rows.length + '条记录吗？', function(r){
		     		if (r){
		     			$.messager.progress({text:"数据处理中，请稍候..."});
		     			$.post("corpManager/corpManagerAction!checkPassCorpBatchRechargeInfo.action", {selections:dataSeqs,customerId:customerId},
		     				function(data){
		     				$.messager.progress("close");
		     				if(data.status == '0'){
		                		var msg = "审核完成.";
		            			
		            			if(data.failList){
		            				msg += "<br>" + data.msg + "<br>";
		        					
		        					var array = eval(data.failList);
		        					
		        					for(var i = 0; i< array.length; i++){
		        						msg += "<br>[序列号:" + array[i].pk.rcgInfoId + ", 人员编号:" + array[i].pk.customerId + ", " + array[i].note + "]";
		        					}
		        				}
		            			
		            			$.messager.alert("消息提示",msg,"info");
		            			
		            			$dgview2.datagrid('load');
		                	}else{
		                		$.messager.alert('消息提示',data.errMsg,'error');
		                	}
		     			}, "json");
		     		}
		     	});
			}else{
				$.messager.alert('系统消息','请选择操作记录','info');
			}
		}
	</script>
  <div class="easyui-layout" data-options="fit:true">
	  <div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		  <div id="tbview2" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" width="100%">
					<tr>
						<td style="padding:0 3px;" class="tableleft">证件号码：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" id="rcgCertNo" class="textinput"/></td>
						<td style="padding:0 3px;" class="tableleft">状态：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" id="rcgState2" class="textinput"/></td>
						<td style="padding:0 3px;" class="tableright">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="queryCorpBatchRechargeInfoDetail()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="checkPass()">审核通过</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-remove'" href="javascript:void(0);" class="easyui-linkbutton" onclick="rechargeFromCorpBatchRechargeInfo()">充值</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-remove'" href="javascript:void(0);" class="easyui-linkbutton" onclick="deleteData()">删除</a>
						</td>
					</tr>
				</table>
			</div>
		    <table id="dgview2"></table>
	  </div>
  </div>
